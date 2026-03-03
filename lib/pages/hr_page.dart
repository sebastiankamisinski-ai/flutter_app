import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';

class HRPage extends StatelessWidget {
  const HRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'HR'),
      body: const Center(
        child: Text('HR Page'),
      ),
    );
  }
}
