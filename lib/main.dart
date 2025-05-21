import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ToDoApp());
}

class Task {
  String title;
  bool isDone;
  DateTime? dueDate;
  String? category;

  Task({
    required this.title,
    this.isDone = false,
    this.dueDate,
    this.category,
  });
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do-App',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: ToDoListPage(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const ToDoListPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<Task> _tasks = [];

  void _addTask(String title, [DateTime? dueDate, String? category]) {
    if (title.trim().isEmpty) return;
    setState(() {
      _tasks.add(Task(title: title.trim(), dueDate: dueDate, category: category));
    });
  }

  void _editTask(int index, Task updatedTask) {
    setState(() {
      _tasks[index] = updatedTask;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showEditDialog(int index) {
    final task = _tasks[index];
    final TextEditingController editController = TextEditingController(text: task.title);
    DateTime? selectedDate = task.dueDate;
    String? selectedCategory = task.category;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editController,
                  decoration: const InputDecoration(labelText: 'Task title'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat.yMMMd().format(selectedDate!)
                          : 'Pick due date',
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text('Select category'),
                  isExpanded: true,
                  items: ['Work', 'Personal', 'Urgent']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (editController.text.trim().isNotEmpty) {
                    _editTask(
                      index,
                      Task(
                        title: editController.text.trim(),
                        isDone: task.isDone,
                        dueDate: selectedDate,
                        category: selectedCategory,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTaskDialog() {
    final TextEditingController newTaskController = TextEditingController();
    DateTime? dueDate;
    String? category;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add New Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newTaskController,
                  decoration: const InputDecoration(labelText: 'Task title'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      dueDate != null
                          ? DateFormat.yMMMd().format(dueDate!)
                          : 'Pick due date',
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            dueDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: category,
                  hint: const Text('Select category'),
                  isExpanded: true,
                  items: ['Work', 'Personal', 'Urgent']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    setStateDialog(() {
                      category = val;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (newTaskController.text.trim().isNotEmpty) {
                    _addTask(newTaskController.text.trim(), dueDate, category);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color? _categoryColor(String? category) {
    switch (category) {
      case 'Work':
        return Colors.blue[400];
      case 'Personal':
        return Colors.green[400];
      case 'Urgent':
        return Colors.red[400];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('To-Do-App'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [Colors.black87, Colors.grey[900]!]
                : [Colors.blue.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _tasks.isEmpty
            ? const Center(
                child: Text(
                  'No tasks yet.\nTap + to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Dismissible(
                    key: ValueKey(task.title + index.toString()),
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (_) => _deleteTask(index),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      margin:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        onTap: () => _showEditDialog(index),
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (val) {
                            setState(() {
                              task.isDone = val ?? false;
                            });
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (task.dueDate != null)
                              Text(DateFormat.yMMMd().format(task.dueDate!)),
                            if (task.dueDate != null && task.category != null)
                              const Text(' • '),
                            if (task.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _categoryColor(task.category!)?.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  task.category!,
                                  style: TextStyle(
                                    color: _categoryColor(task.category!),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.edit),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
