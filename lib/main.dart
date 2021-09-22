import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'stopped', _steps = '0';

  @override
  void initState() {
    super.initState();

    permission();
  }

  void permission() async {
    if (await Permission.activityRecognition.request().isGranted) {
      print("Request Accepted");
      initPlatformState();
    } else {
      print("Request Rejected");
    }
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(
          "Step Counter",
          style: GoogleFonts.darkerGrotesque(fontSize: 40),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Divider(
              thickness: 1.5,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
              child: Card(
                color: Colors.black87.withOpacity(0.7),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 30,
                    right: 20,
                    left: 20,
                  ),
                  child: Column(
                    children: <Widget>[
                      gradientShaderMask(
                        child: Text(
                          _steps.toString(),
                          style: GoogleFonts.ubuntu(
                            fontSize: 70,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        "Steps Today",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
            Spacer(),
            Container(
              padding: EdgeInsets.all(15),
              child: Card(
                color: Colors.black87.withOpacity(0.7),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Icon(
                        _status == 'walking'
                            ? Icons.directions_walk
                            : Icons.accessibility_new,
                        color: Colors.white,
                        size: 100,
                      ),
                      Center(
                        child: Text(
                          "${_status.toUpperCase()}",
                          style: TextStyle(fontSize: 25, color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget gradientShaderMask({required Widget child}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.blue.shade200,
          Colors.blueAccent.shade700,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: child,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Pedometer example app'),
  //       ),
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             Text(
  //               'Steps taken:',
  //               style: TextStyle(fontSize: 30),
  //             ),
  //             Text(
  //               _steps,
  //               style: TextStyle(fontSize: 60),
  //             ),
  //             Divider(
  //               height: 100,
  //               thickness: 0,
  //               color: Colors.white,
  //             ),
  //             Text(
  //               'Pedestrian status:',
  //               style: TextStyle(fontSize: 30),
  //             ),
  //             Icon(
  //               _status == 'walking'
  //                   ? Icons.directions_walk
  //                   : _status == 'stopped'
  //                       ? Icons.accessibility_new
  //                       : Icons.error,
  //               size: 100,
  //             ),
  //             Center(
  //               child: Text(
  //                 _status,
  //                 style: _status == 'walking' || _status == 'stopped'
  //                     ? TextStyle(fontSize: 30)
  //                     : TextStyle(fontSize: 20, color: Colors.red),
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
