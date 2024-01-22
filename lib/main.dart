// import 'dart:developer';
// import 'dart:async';

// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:checklist_champ/model/task.dart';
import 'package:checklist_champ/database/database_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Future<List<Task>>? futureTasks;
  final taskDB = TaskDB();

  @override
  void fetchTasks() {
    futureTasks = taskDB.fetchAll();
  }

  var taskList = <Task>[];
  String currentPage = 'TaskList';
  int bank = 0;

  void addTaskToList(task) {
    taskList.add(task);
    notifyListeners();
  }

  void deleteTask(i) {
    taskList.removeAt(i);
    notifyListeners();
  }

  void changeBankBalance(int value) {
    bank = bank + value;
    notifyListeners();
  }

  void selectPage(page) {
    currentPage = page;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPage = context.watch<MyAppState>().currentPage;

    Widget page;
    switch (currentPage) {
      case 'TaskForm':
        page = TaskForm();
      case 'TaskList':
        page = TaskList();
      default:
        throw UnimplementedError('No widget for $currentPage');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          'Checklist Champ!',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: page,
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.taskList.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text('No Tasks to List, and ${appState.bank} points'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      appState.selectPage('TaskForm');
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
              'You have ${appState.taskList.length} tasks!, and ${appState.bank} points!'),
        ),
        Expanded(
          child: ListView(
            children: [
              // for (var task in appState.taskList)
              for (int i = 0; i < appState.taskList.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(appState.taskList[i].name,
                            style: TextStyle(fontSize: 24)),
                        Spacer(),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () {
                            appState
                                .changeBankBalance(appState.taskList[i].value);
                            appState.deleteTask(i);
                          },
                          child: Icon(Icons.check),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () {
                            appState.deleteTask(i);
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                appState.selectPage('TaskForm');
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class TaskForm extends StatefulWidget {
  const TaskForm({super.key});

  @override
  State<TaskForm> createState() {
    return _TaskFormState();
  }
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final valueController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Task Name:',
              ),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional):',
              ),
            ),
            TextFormField(
              controller: valueController,
              decoration: InputDecoration(labelText: 'Reward Value:'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      appState.selectPage('TaskList');
                    },
                    child: Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    appState.addTaskToList(Task(
                      nameController.text ?? '',
                      descriptionController.text ?? '',
                      int.parse(valueController.text) ?? 0,
                    ));
                    appState.selectPage('TaskList');
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
