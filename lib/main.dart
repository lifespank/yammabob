import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:jiggle/jiggle.dart';
import 'Boblist.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'DogFood.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YammaBob(),
    );
  }
}

class YammaBob extends StatefulWidget {
  @override
  _YammaBobState createState() => _YammaBobState();
}

class _YammaBobState extends State<YammaBob> {
  final JiggleController controller = JiggleController();

  void _jiggleStuff() {
    controller.toggle();
  }

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      print("error");
    }
    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "얌마맘마",
          style: TextStyle(
            fontFamily: 'JejuGothic',
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(children: [
          Jiggle(
            jiggleController: controller,
            child: InkWell(
              child: Image(
                image: AssetImage('img/yamma.png'),
              ),
              onTap: () {
                _jiggleStuff();
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: Text(
              "내가 맘마를 언제 먹었냐면",
              style: TextStyle(
                fontFamily: "JejuGothic",
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(child: BobList()),
        ]),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SpeedDial(
            elevation: 0.0,
            buttonSize: 90,
            childrenButtonSize: 80,
            spaceBetweenChildren: 20,
            icon: Icons.add,
            activeIcon: DogFood.dog_food,
            visible: true,
            children: [
              SpeedDialChild(
                labelStyle: TextStyle(fontFamily: 'JejuGothic'),
                elevation: 0.0,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: Icon(Icons.check),
                label: "지금 줘",
                onTap: () {
                  _bobNow(context);
                },
              ),
              SpeedDialChild(
                labelStyle: TextStyle(fontFamily: 'JejuGothic'),
                elevation: 0.0,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: Icon(Icons.add),
                label: "아까 줬어",
                onTap: () {
                  _bobBefore(context);
                },
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}

void _bobNow(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "지금 밥 줘?",
          style: TextStyle(fontFamily: 'JejuGothic'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "아니",
              style: TextStyle(fontFamily: 'JejuGothic'),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              "응",
              style: TextStyle(fontFamily: 'JejuGothic'),
            ),
            onPressed: () {
              FirebaseFirestore.instance.collection("whenBob").add({
                "when": Timestamp.fromDate(DateTime.now()),
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("맛이쪙")));
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _bobBefore (BuildContext context) {
  TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "언제 줬어?",
          style: TextStyle(fontFamily: 'JejuGothic'),
        ),
        content: DateTimePicker(
          controller: controller,
          type: DateTimePickerType.time,
          timeLabelText: "시간 입력",
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "사실 안 줬어",
              style: TextStyle(fontFamily: 'JejuGothic'),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              "이때 줬어",
              style: TextStyle(fontFamily: 'JejuGothic'),
            ),
            onPressed: () {
              if(controller.text != "") {
                FirebaseFirestore.instance.collection("whenBob").add({
                  "when": DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()) + " ${controller.text}"),
                });
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("맛이쪙")));
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
