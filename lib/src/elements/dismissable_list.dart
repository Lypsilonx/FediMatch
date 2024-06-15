import 'package:flutter/material.dart';

class DismissableList extends StatefulWidget {
  final String title;
  final List<Widget> items;
  final Color? color;
  final IconData? icon;
  final String? emptyMessage;
  final bool initiallyExpanded;
  final BorderRadius borderRadius;
  final void Function(bool expanded)? onStateChanged;
  final void Function(int index)? onDismissed;

  const DismissableList(this.title, this.items,
      {this.color,
      this.icon,
      this.emptyMessage,
      this.initiallyExpanded = false,
      this.borderRadius = const BorderRadius.all(Radius.circular(10)),
      this.onStateChanged,
      this.onDismissed});

  @override
  State<DismissableList> createState() => _DismissableListState();
}

class _DismissableListState extends State<DismissableList> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (expanded) {
        if (widget.onStateChanged != null) {
          widget.onStateChanged!(expanded);
        }
      },
      initiallyExpanded: widget.initiallyExpanded,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius,
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius,
      ),
      leading: widget.icon == null
          ? null
          : Icon(widget.icon, color: widget.color ?? Colors.black),
      title: Text(
        widget.title + " (${widget.items.length})",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      children: widget.items.isEmpty
          ? <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.emptyMessage ?? "Empty",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              )
            ]
          : [
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Icon(Icons.delete, color: Colors.white),
                          )),
                    ),
                    key: Key(index.toString()),
                    onDismissed: (direction) {
                      if (widget.onDismissed != null) {
                        setState(() {
                          widget.onDismissed!(index);
                        });
                      }
                    },
                    child: widget.items[index],
                  );
                },
              ),
            ],
    );
  }
}
