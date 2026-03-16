import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/telpon_controller.dart';

class TelponView extends GetView<TelponController> {
  const TelponView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TelponView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TelponView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
