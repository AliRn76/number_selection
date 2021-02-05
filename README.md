## Example

![Demo](https://github.com/Milvintsiss/number_selection/blob/master/doc/demo%20vertical.gif)
![Demo](https://github.com/Milvintsiss/number_selection/blob/master/doc/demo%20horizontal.gif)
</br></br>
## How to use
- Import The number_selection.dart
```
import 'package:number_selection/number_selection.dart';
```
- And here is the code of example
```
return Scaffold(
   backgroundColor: Colors.deepPurple[400],
   body: SafeArea(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.spaceAround,
       children: <Widget>[
         Center(
           child: NumberSelection(
             initialValue: 1,
             minValue: -10,
             maxValue: 10,
             direction: Axis.vertical,
             withSpring: false,
             onChanged: (int value) => print("value: $value"),
           ),
         ),
         Center(
           child: NumberSelection(
             initialValue: 1,
             minValue: -1,
             maxValue: 10,
             direction: Axis.horizontal,
             withSpring: false,
             onChanged: (int value) => print("value: $value"),
           ),
         ),
       ],
     ),
   ),
 );
```
