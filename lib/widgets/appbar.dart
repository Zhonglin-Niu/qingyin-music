import 'package:flutter/material.dart';

import 'widgets.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  const MyAppBar({
    super.key,
    this.title = "倾音悦",
    this.leading,
  });

  final String title;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: MyText(content: title, fontSize: 18),
        leading: leading,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class MyDynaMicAppBar extends StatelessWidget with PreferredSizeWidget {
  const MyDynaMicAppBar({
    super.key,
    required this.title,
    this.leading,
  });

  final Widget title;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: title,
        leading: leading,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
