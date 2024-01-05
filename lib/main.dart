// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

class Task {
  String name;
  String description;
  int value;

  Task(this.name, this.description, this.value);
}

class MyAppState extends ChangeNotifier {
  var taskList = <Task>[];
  String currentPage = 'TaskList';

  void addTaskToList(task) {
    taskList.add(task);
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
        break;
      case 'TaskList':
        page = TaskList();
        break;
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
        child:
            // Column(children: [
            // TaskForm(),
            page,
        // ]),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var thing = Task('e', 'b', 8);
    appState.addTaskToList(thing);

    if (appState.taskList.isEmpty) {
      return Center(
        child: Text('No Tasks to List'),
      );
    }

    return Column(
      children: [
        Text('You have ${appState.taskList.length} tasks!'),
        Expanded(
          child: ListView(
            children: [
              // Text('You have ${appState.taskList.length} favorites'),
              for (var task in appState.taskList)
                ListTile(
                  title: Text(task.name),
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

    // return Column(
    //   children: [
    //     Text('You have ${appState.taskList.length} favorites'),
    //     SizedBox(
    //       height: 500,
    //       child: ListView(
    //         children: [
    //           // Text('You have ${appState.taskList.length} favorites'),
    //           for (var task in appState.taskList)
    //             ListTile(
    //               title: Text(task.name),
    //             )
    //         ],
    //       ),
    //     ),
    //   ],
    // );
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
            ElevatedButton(
              onPressed: () {
                appState.addTaskToList(Task(
                  nameController.text,
                  descriptionController.text,
                  int.parse(valueController.text),
                ));
              },
              child: Text('Add Task'),
            )
          ],
        ),
      ),
    );
  }
}
