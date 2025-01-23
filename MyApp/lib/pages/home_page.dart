import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceWidth, _deviceHeight;

  String? _newcontent;
  Box? _box;

  @override
  void initState() {
    super.initState();
  }

  _HomePageState();
  @override
  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        titleSpacing: _deviceWidth * 0.05,
        backgroundColor: const Color.fromARGB(255, 76, 54, 244),
        title: Text(
          'My Task APP',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _taskview(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskview() {
    return FutureBuilder(
        future: Hive.openBox('tasks'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _box = snapshot.data;
            return _taskList();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          var task = Task.fromMap(tasks[index]);
          return ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(task.timestamp.toString()),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              color: const Color.fromARGB(255, 54, 177, 244),
            ),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(index, task.toMap());
              setState(() {});
            },
            onLongPress: () {
              _box!.deleteAt(index);
              setState(() {});
            },
          );
        });
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _addTaskDialog,
      backgroundColor: const Color.fromARGB(255, 54, 244, 177),
      child: Icon(Icons.add),
    );
  }

  void _addTaskDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add Task"),
            content: TextField(
              onSubmitted: (value) {
                if (_newcontent != null) {
                  _box!.add(Task(
                          content: _newcontent!,
                          timestamp: DateTime.now(),
                          done: false)
                      .toMap());
                  setState(() {
                    _newcontent = null;
                    Navigator.pop(context);
                  });
                }
              },
              onChanged: (value) {
                setState(() {
                  _newcontent = value;
                });
              },
            ),
          );
        });
  }
}
