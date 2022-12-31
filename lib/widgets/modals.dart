import 'package:flutter/material.dart';
import 'package:get/get.dart';

void successInfo({String msg = ""}) {
  Get.snackbar(
    "成功",
    msg,
    icon: const Icon(
      Icons.check_circle,
      color: Colors.green,
    ),
    backgroundColor: Colors.white,
    duration: const Duration(seconds: 2),
  );
}

void failInfo({String msg = ""}) {
  Get.snackbar(
    "失败",
    msg,
    icon: const Icon(
      Icons.error,
      color: Colors.red,
    ),
    backgroundColor: Colors.white,
    duration: const Duration(seconds: 2),
  );
}
