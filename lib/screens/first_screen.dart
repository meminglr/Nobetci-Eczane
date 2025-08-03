import 'package:flutter/material.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/widgets/companents.dart';

class FirstScreen extends StatefulWidget {
  final Companents companents;
  final HomeController controller;
  const FirstScreen({
    super.key,
    required this.companents,
    required this.controller,
  });

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Nöbetçi Eczane",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 50,
              ),
            ),
            widget.companents.firstScreenIl(context, widget.controller , (){setState(() {
              
            });} ),
            widget.companents.firstScreenIlce(context, widget.controller, (){setState(() {
              
            });}),
          ],
        ),
      ),
    );
  }
}
