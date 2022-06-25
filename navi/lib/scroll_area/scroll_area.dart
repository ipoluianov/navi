import 'package:flutter/material.dart';

class ScrollArea extends StatefulWidget {
  final Widget child;

  const ScrollArea({required this.child, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScrollAreaState();
  }
}

class ScrollAreaState extends State<ScrollArea> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.loose,
        children: [
          Container(
            color: Colors.green
          ),
          widget.child,
        ],
      ),
    );
  }
}
