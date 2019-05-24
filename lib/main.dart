import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {

  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  
  final GlobalKey<AnimatedCircularChartState> key =
    GlobalKey<AnimatedCircularChartState>();
  bool press = false;
  int choice = -1;
  double percent = 0;
  String value = "?";
  
  @override
  Widget build(BuildContext context) {
    return GestureCustom(
      duration: Duration(milliseconds: 50),
      onTap: () async {
        // print("Tap");
        var tmp = await Navigator
          .push(context, MaterialPageRoute(builder: (context) => ChoiceGrid()));
        if (tmp != null)
          choice = tmp;
        setState(() {
            value = "?";
            key.currentState.updateData([]);
          });
      },
      startPress: () {
        // print("Start press");
        press = true;
        percent = 0;
        if (value == "?")
          _wait();
      },
      endPress: () {
        // print("End press");
        press = false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedCircularChart(
            key: key,
            size: Size(300, 300),
            initialChartData: [],
            chartType: CircularChartType.Radial,
            edgeStyle: SegmentEdgeStyle.round,
            percentageValues: true,
            duration: Duration(milliseconds: 30),
            holeLabel: value,
            labelStyle: TextStyle(
              fontSize: 200,
              color: Colors.white
            ),
          )
        )
      )
    );
  }

  _wait() {
    if (press) {
      // print("percent: $percent");
      Future.delayed(Duration(milliseconds: 30), () {
        if (percent >= 100)
          setState(() {
            key.currentState.updateData(<CircularStackEntry>[]);
            value = choice.toString();
          });
        else if (choice > 0) {
            percent += 10;
            key.currentState.updateData(<CircularStackEntry>[
              CircularStackEntry(
                <CircularSegmentEntry>[
                  CircularSegmentEntry(
                    percent,
                    Colors.white,
                  )
                ],
              ),
            ]);
        }
        _wait();
      });
    }
    else
      setState(() {
        key.currentState.updateData(<CircularStackEntry>[]);
      });
  }
}

class ChoiceGrid extends StatelessWidget {
  final List<int> choice = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: GridView.builder(
          itemCount: choice.length + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: EdgeInsets.all(5.0),
              child: RaisedButton(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.white,
                    width: 2.0
                  ),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                onPressed: () {
                  Navigator.pop(context,
                    (index < choice.length) ? choice[index] : null);
                },
                child: () {
                  if (index < choice.length)
                    return Text(choice[index].toString(),
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white
                      ),
                    );
                  else
                    return Transform.rotate(
                      angle: 1.0,
                      child: Icon(
                        Icons.play_arrow,
                        size: 60,
                        color: Colors.white
                      )
                    );
                }()
              )
            );
          }
        )
      )
    );
  }
}

class GestureCustom extends StatefulWidget {

  final Duration duration;
  final Function onTap;
  final Function startPress;
  final Function endPress;
  final Widget child;

  GestureCustom({this.duration, this.onTap, this.startPress, this.endPress, this.child});

  State<StatefulWidget> createState() {
    return _GestureCustom();
  }
}

class _GestureCustom extends State<GestureCustom> {
  bool press = false;
  DateTime time;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onHorizontalDragEnd: (_) {
        _up();
      },
      onVerticalDragEnd: (_) {
        _up();
      },
      onTapDown: (_) async {
        _down();
        Future.delayed(widget.duration, () {
          if (press)
            widget.startPress();
        });
      },
      onTapUp: (_) {
        _up();
      }
    );
  }

  _up() {
    if (press) {
      Duration duration = DateTime.now().difference(time);
      _onFunction(duration);
      press = false;
    }
  }

  _down() {
    if (!press) {
      time = DateTime.now();
      press = true;
    }
  }

  _onFunction(Duration duration) {
    if (duration < widget.duration)
      widget.onTap();
    else
      widget.endPress();
  }
}