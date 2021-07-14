import 'package:flutter/material.dart';
import 'package:number_selection/number_selection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.deepPurple[400],
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Center(
                child: NumberSelection(
                  theme: NumberSelectionTheme(
                      draggableCircleColor: Colors.blue,
                      iconsColor: Colors.white,
                      numberColor: Colors.white,
                      backgroundColor: Colors.deepPurpleAccent,
                      outOfConstraintsColor: Colors.deepOrange),
                  initialValue: 1,
                  minValue: -10,
                  maxValue: 10,
                  direction: Axis.vertical,
                  withSpring: true,
                  onChanged: (int value) => print("value: $value"),
                  enableOnOutOfConstraintsAnimation: true,
                  onOutOfConstraints: () =>
                      print("This value is too high or too low"),
                ),
              ),
              Center(
                child: NumberSelection(
                  initialValue: 1,
                  minValue: -1,
                  maxValue: 10,
                  direction: Axis.horizontal,
                  withSpring: true,
                  onChanged: (int value) => print("value: $value"),
                  enableOnOutOfConstraintsAnimation: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
