import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'modelclass.dart';
import 'dbhelper.dart';

class TodoApp extends StatefulWidget {
  final DateTime selectedDay;
  TodoApp({required this.selectedDay});

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final DBHelper _dbHelper = DBHelper();
  late DateTime _selectedDay;
  List<Task> _tasks = [];
  TextEditingController _taskController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0); // Default start time
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0); // Default end time

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    _loadTasks();
  }

  // Load tasks for the selected date
  void _loadTasks() async {
    List<Task> tasks = await _dbHelper.getTasksByDate(_selectedDay);
    setState(() {
      _tasks = tasks;
    });
  }

  // Add a new task to the database
  void _addTask() async {
    if (_taskController.text.isEmpty) return;
    DateTime start = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _startTime.hour,
      _startTime.minute,
    );
    DateTime end = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _endTime.hour,
      _endTime.minute,
    );

    Task newTask = Task(
      taskDescription: _taskController.text,
      startTime: start,
      endTime: end,
    );

    await _dbHelper.insertTask(newTask);
    _taskController.clear();
    _loadTasks();
  }

  // Mark task as completed
  void _toggleCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _dbHelper.updateTaskCompletion(task);
    _loadTasks();
  }

  // Show time picker and update the start time
  void _selectStartTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  // Show time picker and update the end time
  void _selectEndTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true, // <-- very important for keyboard behavior
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // <-- keyboard height
            top: 8.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // <-- important to shrink height dynamically
              children: [
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(labelText: 'Enter a new task'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Start Time:'),
                    SizedBox(width: 10),
                    Text('${_startTime.format(context)}'),
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: _selectStartTime,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('End Time:'),
                    SizedBox(width: 10),
                    Text('${_endTime.format(context)}'),
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: _selectEndTime,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(onPressed: _addTask, child: Text('Add Task')),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' ${DateFormat.yMMMd().format(_selectedDay)}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return showBottomSheet();
        },
        child: Text('Add'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  Task task = _tasks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          _toggleCompletion(task);
                        },
                      ),
                      title: Text(task.taskDescription),
                      subtitle: Text(
                        'From ${DateFormat.jm().format(task.startTime)} to ${DateFormat.jm().format(task.endTime)}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
