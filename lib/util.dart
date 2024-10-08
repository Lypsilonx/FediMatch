import 'dart:math';
import 'dart:typed_data';

import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
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

  static List<BoxShadow> boxShadow(BuildContext context) {
    return [
      BoxShadow(
          offset: Offset(0, 4),
          blurRadius: 10,
          spreadRadius: -5,
          color: Theme.of(context).colorScheme.primary.withAlpha(100))
    ];
  }

  static Widget ImageErrorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: 10),
                Text(
                  "Error loading image",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                Navigator.of(context).pop();
                confirmAction();
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

  static void showReportDialog(
      BuildContext context, Account account, void Function() onReport,
      {Status? status}) {
    String reason = "other";
    InputTextFieldController commentController = new InputTextFieldController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Report " +
                  account.getDisplayName() +
                  (status != null ? " for a status" : "")),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Why do you want to report this user?"),
                  DropdownButton(
                      value: reason,
                      items: [
                        DropdownMenuItem(child: Text("Spam"), value: "spam"),
                        DropdownMenuItem(
                            child: Text("Illegal content"), value: "legal"),
                        DropdownMenuItem(child: Text("Other"), value: "other"),
                      ],
                      onChanged: (value) {
                        setState(() {
                          reason = value.toString();
                        });
                      }),
                  Text("Comment (optional)"),
                  TextField(
                    controller: commentController,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: null,
                    maxLength: 1000,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Report " + account.getDisplayName()),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Util.executeWhenOK(
                      Mastodon.report(
                        account,
                        SettingsController.instance.accessToken,
                        statusIds: status != null ? [status.id] : null,
                        category: reason,
                        comment: commentController.text,
                      ),
                      context,
                      onOK: onReport,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void askForPassword(
      BuildContext context, void Function(String password) confirmAction) {
    InputTextFieldController controller = new InputTextFieldController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter new Matching-Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Choose a secure password to encrypt your matching data.\nYou will need this password to log in on other devices."),
              TextFormField(
                controller: controller,
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                if (controller.text.isEmpty) {
                  showErrorScaffold(context, "Password cannot be empty.");
                  return;
                }

                Navigator.of(context).pop();
                confirmAction(controller.text);
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

  static SecureRandom secureRandom(String password) {
    final secureRandom = FortunaRandom();

    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      // add 32 random bytes (from 0 to 255) to the seed by iterating through the password
      seeds.add(min(password.codeUnitAt(i % password.length), 255));
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
