import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box _box;
  bool textinputs = false;
  TextEditingController myController = TextEditingController();
  String today = DateFormat('dd MMM yyyy').format(DateTime.now());
  Duration d = Duration(hours: 24);
  bool lightMode = true;

  @override
  void initState() {
    super.initState();

    _box = Hive.box('hivebox');
    // Initialize starting time only if it's not already saved
    calculateTimeLeftToday();

    startTimer();
  }

  void calculateTimeLeftToday() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    d = midnight.difference(now);
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        d = d - Duration(seconds: 1);
        if (d.isNegative || d.inSeconds == 0) {
          calculateTimeLeftToday();
        }
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes % 60)}:"
        "${twoDigits(duration.inSeconds % 60)}";
  }

  void write(Map newTask) {
    _box.add(newTask);
    myController.clear();
  }

  void taskRemoval(i) {
    setState(() {
      _box.deleteAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightMode ? Colors.white : Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          setState(() {
            textinputs = true;
          });
        },
      ),
      body: Stack(
        children: [
          // Banner image with timer
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/dasdas.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatDuration(d),
                    style: TextStyle(
                      fontSize: 60,
                      color: const Color.fromARGB(255, 196, 255, 201),

                      fontFamily: 'Wooden Log',
                    ),
                  ),
                  Text(
                    today,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 196, 255, 201),
                      fontSize: 25,
                      fontFamily: 'Wooden Log',
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            // Rounded container with tasks
            margin: EdgeInsets.only(top: 140),
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: lightMode ? Colors.white : Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child:
                _box.length > 0
                    ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "have you finished ?",
                              style: TextStyle(
                                fontSize: 16,
                                color: lightMode ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Green Love',
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap:
                                true, // Important for using ListView inside Column
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _box.length,
                            itemBuilder: (BuildContext context, int index) {
                              final task = _box.getAt(index);

                              if (task is Map && task.containsKey('title')) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 10,
                                  ),
                                  child: Slidable(
                                    key: ValueKey(index),
                                    endActionPane: ActionPane(
                                      motion: const StretchMotion(),
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          onPressed:
                                              (context) => taskRemoval(index),
                                          icon: Icons.delete,
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              lightMode
                                                  ? Colors.grey
                                                  : Colors.white,
                                        ),
                                        color:
                                            lightMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      child: CheckboxListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        checkColor: Colors.white,
                                        activeColor: Colors.green,
                                        // hoverColor: Colors.green[900],
                                        title: Text(
                                          task['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                lightMode
                                                    ? Colors.black
                                                    : Colors.white,
                                            decoration:
                                                task['completion']
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                          ),
                                        ),
                                        value: task['completion'],
                                        onChanged: (value) {
                                          setState(() {
                                            _box.putAt(index, {
                                              'title': task['title'],
                                              'completion': value,
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      ),
                    )
                    : Center(
                      child: Text(
                        "No tasks for today",
                        style: TextStyle(
                          fontSize: 16,
                          color: lightMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                lightMode = !lightMode;
              });
            },
            icon: Icon(Icons.lightbulb_circle, size: 30, color: Colors.white),
          ),

          // Input box UI
          if (textinputs)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                // color: Colors.amber,
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(30),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lightMode ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            cursorColor: Colors.green,
                            style: TextStyle(
                              color: lightMode ? Colors.black : Colors.white,
                            ),
                            controller: myController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 25,
                              ),

                              prefixIcon: Icon(Icons.pending_actions_sharp),
                              hintText: "Add your task",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: lightMode ? Colors.grey : Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 20,
                                ),

                                overlayColor: Colors.green[900],
                              ),
                              onPressed: () {
                                setState(() {
                                  textinputs = false;
                                  myController.clear();
                                });
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 20,
                                ),

                                overlayColor: Colors.green[900],
                              ),
                              onPressed: () {
                                if (myController.text.trim().isNotEmpty) {
                                  write({
                                    'title': myController.text.trim(),
                                    'completion': false,
                                  });
                                }
                                setState(() {
                                  textinputs = false;
                                });
                              },
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
