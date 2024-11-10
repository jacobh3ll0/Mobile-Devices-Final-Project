import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page"), automaticallyImplyLeading: false),
    );
  }

}