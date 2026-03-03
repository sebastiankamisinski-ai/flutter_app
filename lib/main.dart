import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

String? geminiApiKey;
Employee? loggedInEmployee;

Future<void> main() async {
  await dotenv.load();
  geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: loggedInEmployee == null ? const LoginPage() : const StartPage(),
    );
  }
}

// Employee Model
class Employee {
  final int id;
  final String name;
  final String employeeNumber;
  final String position;
  final String department;
  final String email;

  Employee({
    required this.id,
    required this.name,
    required this.employeeNumber,
    required this.position,
    required this.department,
    required this.email,
  });
}

// Demo Employee Data
final List<Employee> demoEmployees = [
  Employee(
    id: 1,
    name: 'Jan Kowalski',
    employeeNumber: '10001',
    position: 'Senior Developer',
    department: 'IT',
    email: 'jan.kowalski@company.com',
  ),
  Employee(
    id: 2,
    name: 'Maria Nowak',
    employeeNumber: '10002',
    position: 'Project Manager',
    department: 'Management',
    email: 'maria.nowak@company.com',
  ),
  Employee(
    id: 3,
    name: 'Piotr Lewandowski',
    employeeNumber: '10003',
    position: 'Designer',
    department: 'Design',
    email: 'piotr.lewandowski@company.com',
  ),
  Employee(
    id: 4,
    name: 'Anna Wiśniewski',
    employeeNumber: '10004',
    position: 'HR Specialist',
    department: 'HR',
    email: 'anna.wisniewski@company.com',
  ),
  Employee(
    id: 5,
    name: 'Michał Dąbrowski',
    employeeNumber: '10005',
    position: 'QA Engineer',
    department: 'Quality Assurance',
    email: 'michal.dabrowski@company.com',
  ),
  Employee(
    id: 6,
    name: 'Katarzyna Zielińska',
    employeeNumber: '10006',
    position: 'Business Analyst',
    department: 'Business',
    email: 'katarzyna.zielinska@company.com',
  ),
];

// Shared AppBar Widget
PreferredSizeWidget buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        if (loggedInEmployee != null)
          Text(
            'Zalogowany: ${loggedInEmployee!.name}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const StartPage()),
          );
        },
        child: const Text('Start', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PracownicyPage()),
          );
        },
        child: const Text('Pracownicy', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HRPage()),
          );
        },
        child: const Text('HR', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RCPPage()),
          );
        },
        child: const Text('RCP', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          loggedInEmployee = null;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: const Text('Wyloguj', style: TextStyle(color: Colors.red)),
      ),
    ],
  );
}

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _login(Employee employee) {
    setState(() {
      loggedInEmployee = employee;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const StartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Logowanie'),
      ),
      body: ListView.builder(
        itemCount: demoEmployees.length,
        itemBuilder: (context, index) {
          final employee = demoEmployees[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(employee.name),
            subtitle: Text(employee.position),
            onTap: () => _login(employee),
          );
        },
      ),
    );
  }
}

// Start Page
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int _counter = 0;
  String _geminiResponse = '';
  bool _isLoading = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void showHelloWorld() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: const Text('Hello World!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> callGemini() async {
    if (geminiApiKey == null || geminiApiKey!.isEmpty) {
      setState(() {
        _geminiResponse = 'Error: GEMINI_API_KEY not found in .env file';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _geminiResponse = 'Loading...';
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: geminiApiKey!,
      );

      final response = await model.generateContent([
        Content.text('Hello! What is Flutter?'),
      ]);

      setState(() {
        _geminiResponse = response.text ?? 'No response received';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _geminiResponse = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Start'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : callGemini,
              child: _isLoading ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ) : const Text('Call Gemini API'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: showHelloWorld,
              child: const Text('Show Hello World'),
            ),
            if (_geminiResponse.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_geminiResponse),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Pracownicy Page
class PracownicyPage extends StatefulWidget {
  const PracownicyPage({super.key});

  @override
  State<PracownicyPage> createState() => _PracownicyPageState();
}

class _PracownicyPageState extends State<PracownicyPage> {
  late List<Employee> employees;
  late List<Employee> filteredEmployees;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    employees = List.from(demoEmployees);
    filteredEmployees = List.from(employees);
    searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterEmployees() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredEmployees = List.from(employees);
      } else {
        final query = searchController.text.toLowerCase();
        filteredEmployees = employees
            .where((emp) =>
                emp.name.toLowerCase().contains(query) ||
                emp.employeeNumber.toLowerCase().contains(query) ||
                emp.position.toLowerCase().contains(query) ||
                emp.department.toLowerCase().contains(query) ||
                emp.email.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isEmailDuplicate(String email, {int? exceptId}) {
    return employees.any((emp) => 
      emp.email.toLowerCase() == email.toLowerCase() && 
      (exceptId == null || emp.id != exceptId)
    );
  }

  bool _isEmployeeNumberDuplicate(String employeeNumber, {int? exceptId}) {
    return employees.any((emp) => 
      emp.employeeNumber == employeeNumber && 
      (exceptId == null || emp.id != exceptId)
    );
  }

  void _showEmployeeForm({Employee? employee}) {
    final isEditing = employee != null;
    final nameController = TextEditingController(text: employee?.name ?? '');
    final employeeNumberController = TextEditingController(text: employee?.employeeNumber ?? '');
    final positionController = TextEditingController(text: employee?.position ?? '');
    final departmentController = TextEditingController(text: employee?.department ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edytuj pracownika' : 'Dodaj pracownika'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Imię i nazwisko'),
                ),
                TextField(
                  controller: employeeNumberController,
                  decoration: const InputDecoration(labelText: 'Numer płacowy'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Stanowisko'),
                ),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Dział'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    employeeNumberController.text.isEmpty ||
                    positionController.text.isEmpty ||
                    departmentController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Błąd'),
                        content: const Text('Wypełnij wszystkie pola!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                if (_isEmployeeNumberDuplicate(employeeNumberController.text, exceptId: employee?.id)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Błąd'),
                        content: const Text('Ten numer płacowy jest już używany!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                if (!_isValidEmail(emailController.text)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Błąd'),
                        content: const Text('Podaj poprawny adres email!\nFormat: example@domain.com'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );                  return;
                }

                if (_isEmailDuplicate(emailController.text, exceptId: employee?.id)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Błąd'),
                        content: const Text('Ten email jest już używany!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                setState(() {
                  if (isEditing) {
                    final index = employees.indexWhere((e) => e.id == employee.id);
                    employees[index] = Employee(
                      id: employee.id,
                      name: nameController.text,
                      employeeNumber: employeeNumberController.text,
                      position: positionController.text,
                      department: departmentController.text,
                      email: emailController.text,
                    );
                  } else {
                    final newId = employees.isEmpty
                        ? 1
                        : employees.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
                    employees.add(Employee(
                      id: newId,
                      name: nameController.text,
                      employeeNumber: employeeNumberController.text,
                      position: positionController.text,
                      department: departmentController.text,
                      email: emailController.text,
                    ));
                  }
                });
                _filterEmployees();

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Zapisz' : 'Dodaj'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEmployee(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usunąć pracownika?'),
          content: const Text('Czy na pewno chcesz usunąć tego pracownika?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  employees.removeWhere((e) => e.id == id);
                });
                _filterEmployees();
                Navigator.of(context).pop();
              },
              child: const Text('Usuń', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pracownicy'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const StartPage()),
              );
            },
            child: const Text('Start', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Pracownicy', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HRPage()),
              );
            },
            child: const Text('HR', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RCPPage()),
              );
            },
            child: const Text('RCP', style: TextStyle(color: Colors.black)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Szukaj pracownika...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showEmployeeForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('Nr Płacowy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                Expanded(flex: 2, child: Text('Imię', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                Expanded(flex: 2, child: Text('Stanowisko', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                Expanded(flex: 1, child: Text('Dział', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                Expanded(flex: 1, child: Text('Akcje', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
              ],
            ),
          ),
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(
                    child: Text('Brak pracowników'),
                  )
                : ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text(employee.employeeNumber)),
                                Expanded(flex: 2, child: Text(employee.name)),
                                Expanded(flex: 2, child: Text(employee.position)),
                                Expanded(flex: 1, child: Text(employee.department)),
                                Expanded(flex: 2, child: Text(employee.email, style: const TextStyle(color: Colors.blue))),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () => _showEmployeeForm(employee: employee),
                                        tooltip: 'Edytuj',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                        onPressed: () => _deleteEmployee(employee.id),
                                        tooltip: 'Usuń',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey[300]),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// HR Page
class HRPage extends StatelessWidget {
  const HRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'HR'),
      body: const Center(
        child: Text('HR Page'),
      ),
    );
  }
}

// RCP Page
class RCPPage extends StatefulWidget {
  const RCPPage({super.key});

  @override
  State<RCPPage> createState() => _RCPPageState();
}

class WorkSession {
  final DateTime startTime;
  final DateTime endTime;

  WorkSession({
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}

class _RCPPageState extends State<RCPPage> {
  bool _isWorking = false;
  DateTime? _workStartTime;
  Duration _totalWorkTime = Duration.zero;
  late DateTime _lastWorkStart;
  List<WorkSession> _workSessions = [];

  void _startWork() {
    setState(() {
      _isWorking = true;
      _workStartTime = DateTime.now();
      _lastWorkStart = _workStartTime!;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Praca rozpoczęta o ${_workStartTime!.hour}:${_workStartTime!.minute.toString().padLeft(2, '0')}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _stopWork() {
    if (_workStartTime != null) {
      final workDuration = DateTime.now().difference(_lastWorkStart);
      final endTime = DateTime.now();
      
      setState(() {
        _totalWorkTime = Duration(
          hours: _totalWorkTime.inHours + workDuration.inHours,
          minutes: (_totalWorkTime.inMinutes % 60) + (workDuration.inMinutes % 60),
        );
        _workSessions.add(WorkSession(
          startTime: _lastWorkStart,
          endTime: endTime,
        ));
        _isWorking = false;
        _workStartTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Praca zatrzymana. Czas pracy: ${workDuration.inMinutes} minut'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'RCP'),
      body: Column(
        children: [
          // Summary Section
          Container(
            color: Colors.blue[50],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Podsumowanie',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final currentTime = _isWorking
                                ? DateTime.now().difference(_lastWorkStart).inSeconds
                                : 0;
                            final totalSeconds = _totalWorkTime.inSeconds + currentTime;
                            final hours = totalSeconds ~/ 3600;
                            final minutes = (totalSeconds % 3600) ~/ 60;

                            return Text(
                              '${hours}h ${minutes}m',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                        const Text(
                          'Łączny czas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${_workSessions.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          'Sesji pracy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Work Sessions List
          if (_workSessions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _workSessions.length,
                itemBuilder: (context, index) {
                  final session = _workSessions[index];
                  final duration = session.duration;
                  final minutes = duration.inMinutes;
                  
                  return ListTile(
                    leading: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    title: Text(
                      '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')} - ${session.endTime.hour.toString().padLeft(2, '0')}:${session.endTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Text(
                      '$minutes min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'Brak sesji pracy',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          // Control Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            margin: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: [
                Text(
                  _isWorking ? 'Praca w toku' : 'Praca zatrzymana',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isWorking ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                if (_workStartTime != null)
                  Column(
                    children: [
                      Text(
                        'Start: ${_workStartTime!.hour}:${_workStartTime!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    final currentTime = _isWorking
                        ? DateTime.now().difference(_lastWorkStart).inSeconds
                        : 0;
                    final totalSeconds = _totalWorkTime.inSeconds + currentTime;
                    final hours = totalSeconds ~/ 3600;
                    final minutes = (totalSeconds % 3600) ~/ 60;
                    final seconds = totalSeconds % 60;

                    return Text(
                      'Łączny czas: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isWorking ? null : _startWork,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start pracy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isWorking ? _stopWork : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop pracy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
