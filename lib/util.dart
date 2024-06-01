import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import "package:pointycastle/export.dart";

class Util {
  static void executeWhenOK(
    Future<String> result,
    BuildContext context, {
    void Function()? onOK,
  }) {
    result.then((result) {
      if (result == "OK") {
        if (onOK != null) onOK();
      } else {
        showErrorScaffold(context, result);
      }
    });
  }

  static void showErrorScaffold(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: new TextStyle(
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      showCloseIcon: true,
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  static void popUpDialog(BuildContext context, String title, String content,
      String confirmText, void Function() confirmAction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(confirmText),
              onPressed: () {
                confirmAction();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Crypotography {
  // Create an rsa key pair
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      SecureRandom secureRandom,
      {int bitLength = 512}) {
    // Create an RSA key generator and initialize it

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom));

    // Use the generator

    final pair = keyGen.generateKeyPair();

    // Cast the generated key pair into the RSA key types

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  static SecureRandom secureRandom() {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }

  static RSAPublicKey parsePublicKey(String publicKey) {
    final parts = publicKey.split(':');
    return RSAPublicKey(
      BigInt.parse(parts[0]),
      BigInt.parse(parts[1]),
    ); // modulus, exponent
  }

  static RSAPrivateKey parsePrivateKey(String privateKey) {
    final parts = privateKey.split(':');
    return RSAPrivateKey(
      BigInt.parse(parts[0]),
      BigInt.parse(parts[1]),
      parts.length > 2 ? BigInt.parse(parts[2]) : null,
      parts.length > 3 ? BigInt.parse(parts[3]) : null,
    ); // modulus, privateExponent, p, q
  }

  static String fromPublicKey(RSAPublicKey publicKey) {
    return publicKey.modulus.toString() + ":" + publicKey.exponent.toString();
  }

  static String fromPrivateKey(RSAPrivateKey privateKey) {
    return privateKey.modulus.toString() +
        ":" +
        privateKey.privateExponent.toString() +
        (privateKey.p != null ? ":" + privateKey.p.toString() : "") +
        (privateKey.q != null ? ":" + privateKey.q.toString() : "");
  }

  static List<int> rsaEncrypt(String publicKey, String dataToEncrypt) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(
          true,
          PublicKeyParameter<RSAPublicKey>(
              parsePublicKey(publicKey))); // true=encrypt

    return _processInBlocks(
        encryptor, Uint8List.fromList(dataToEncrypt.codeUnits));
  }

  static String rsaDecrypt(String privateKey, List<int> cipherText) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(
          false,
          PrivateKeyParameter<RSAPrivateKey>(
              parsePrivateKey(privateKey))); // false=decrypt

    return String.fromCharCodes(
        _processInBlocks(decryptor, Uint8List.fromList(cipherText)));
  }

  static Uint8List _processInBlocks(
      AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }
}
