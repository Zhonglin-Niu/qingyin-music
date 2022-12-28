import 'package:flutter/material.dart';
export 'playbar.dart';
export 'appbar.dart';

class MyText extends StatelessWidget {
  const MyText({
    super.key,
    this.content = "0.0",
    this.fontSize = 16,
    this.color = Colors.white,
    this.align = TextAlign.left,
  });

  final String content;
  final double fontSize;
  final Color color;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}

class MyShadowContainer extends StatelessWidget {
  final Widget child;
  const MyShadowContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue.withOpacity(.7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2.0, 2.0),
            blurRadius: 1.0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class ShadowContainer extends Container {
  final double circularRadius;
  ShadowContainer({
    super.key,
    super.alignment,
    super.width,
    super.height,
    super.child,
    super.clipBehavior,
    super.color,
    super.constraints,
    super.foregroundDecoration,
    super.margin,
    super.padding,
    super.transform,
    super.transformAlignment,
    this.circularRadius = 10,
  }) : super(
          decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(.7),
            borderRadius: BorderRadius.circular(circularRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(2.0, 2.0),
                blurRadius: 1.0,
              ),
            ],
          ),
        );
}
