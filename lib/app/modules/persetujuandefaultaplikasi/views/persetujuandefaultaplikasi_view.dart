import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/persetujuandefaultaplikasi_controller.dart';

class PersetujuandefaultaplikasiView
    extends GetView<PersetujuandefaultaplikasiController> {
  const PersetujuandefaultaplikasiView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PersetujuandefaultaplikasiView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PersetujuandefaultaplikasiView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
