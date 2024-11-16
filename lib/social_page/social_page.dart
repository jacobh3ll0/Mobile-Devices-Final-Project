import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Social Page"),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          "Social page to be completed",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}