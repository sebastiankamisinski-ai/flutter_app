import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/employee.dart';
import '../globals.dart';
import '../widgets/app_bar.dart';

class PracownicyPage extends StatefulWidget {
  const PracownicyPage({super.key});

  @override
  State<PracownicyPage> createState() => _PracownicyPageState();
}

class _PracownicyPageState extends State<PracownicyPage> {
  static const _noGroupLabel = 'Bez grupy';

  late TextEditingController searchController;
  late List<Employee> filteredEmployees;
  final List<String> _groups = ['Zespół A', 'Zespół B'];
  final Map<int, String?> _employeeGroupById = {};

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
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
            .where(
              (emp) =>
                  emp.name.toLowerCase().contains(query) ||
                  emp.employeeNumber.toLowerCase().contains(query) ||
                  emp.position.toLowerCase().contains(query) ||
                  emp.department.toLowerCase().contains(query) ||
                  emp.email.toLowerCase().contains(query) ||
                  (_employeeGroupById[emp.id] ?? '').toLowerCase().contains(
                    query,
                  ),
            )
            .toList();
      }
    });
  }

  void _showCreateGroupDialog() {
    final groupController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nowa grupa pracowników'),
          content: TextField(
            controller: groupController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nazwa grupy'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                final groupName = groupController.text.trim();
                if (groupName.isEmpty) {
                  return;
                }

                final exists = _groups.any(
                  (group) => group.toLowerCase() == groupName.toLowerCase(),
                );
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Taka grupa już istnieje.')),
                  );
                  return;
                }

                setState(() {
                  _groups.add(groupName);
                  _groups.sort(
                    (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
                  );
                });

                Navigator.of(context).pop();
              },
              child: const Text('Utwórz'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isEmailDuplicate(String email, {int? exceptId}) {
    return employees.any(
      (emp) =>
          emp.email.toLowerCase() == email.toLowerCase() &&
          (exceptId == null || emp.id != exceptId),
    );
  }

  bool _isEmployeeNumberDuplicate(String employeeNumber, {int? exceptId}) {
    return employees.any(
      (emp) =>
          emp.employeeNumber == employeeNumber &&
          (exceptId == null || emp.id != exceptId),
    );
  }

  void _showEmployeeForm({Employee? employee}) {
    final isEditing = employee != null;
    final nameController = TextEditingController(text: employee?.name ?? '');
    final employeeNumberController = TextEditingController(
      text: employee?.employeeNumber ?? '',
    );
    final positionController = TextEditingController(
      text: employee?.position ?? '',
    );
    final departmentController = TextEditingController(
      text: employee?.department ?? '',
    );
    final emailController = TextEditingController(text: employee?.email ?? '');
    String? selectedGroup = employee == null
        ? null
        : _employeeGroupById[employee.id];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edytuj pracownika' : 'Dodaj pracownika'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Imię i nazwisko',
                      ),
                    ),
                    TextField(
                      controller: employeeNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Numer płacowy',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    TextField(
                      controller: positionController,
                      decoration: const InputDecoration(
                        labelText: 'Stanowisko',
                      ),
                    ),
                    TextField(
                      controller: departmentController,
                      decoration: const InputDecoration(labelText: 'Dział'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      value: selectedGroup,
                      decoration: const InputDecoration(labelText: 'Grupa'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(_noGroupLabel),
                        ),
                        ..._groups.map(
                          (group) => DropdownMenuItem<String?>(
                            value: group,
                            child: Text(group),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGroup = value;
                        });
                      },
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

                    if (_isEmployeeNumberDuplicate(
                      employeeNumberController.text,
                      exceptId: employee?.id,
                    )) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Błąd'),
                            content: const Text(
                              'Ten numer płacowy jest już używany!',
                            ),
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
                            content: const Text(
                              'Podaj poprawny adres email!\nFormat: example@domain.com',
                            ),
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

                    if (_isEmailDuplicate(
                      emailController.text,
                      exceptId: employee?.id,
                    )) {
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
                        final index = employees.indexWhere(
                          (e) => e.id == employee.id,
                        );
                        employees[index] = Employee(
                          id: employee.id,
                          name: nameController.text,
                          employeeNumber: employeeNumberController.text,
                          position: positionController.text,
                          department: departmentController.text,
                          email: emailController.text,
                        );
                        _employeeGroupById[employee.id] = selectedGroup;
                      } else {
                        final newId = employees.isEmpty
                            ? 1
                            : employees
                                      .map((e) => e.id)
                                      .reduce((a, b) => a > b ? a : b) +
                                  1;
                        employees.add(
                          Employee(
                            id: newId,
                            name: nameController.text,
                            employeeNumber: employeeNumberController.text,
                            position: positionController.text,
                            department: departmentController.text,
                            email: emailController.text,
                          ),
                        );
                        _employeeGroupById[newId] = selectedGroup;
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
                  _employeeGroupById.remove(id);
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
    final groupedEmployees = <String, List<Employee>>{};

    for (final employee in filteredEmployees) {
      final groupName = _employeeGroupById[employee.id] ?? _noGroupLabel;
      groupedEmployees.putIfAbsent(groupName, () => []).add(employee);
    }

    final groupNames = groupedEmployees.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      appBar: buildAppBar(context, 'Pracownicy'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Szukaj pracownika lub grupy',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _showCreateGroupDialog,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Nowa grupa'),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Nr Płacowy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Imię',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Grupa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Stanowisko',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Dział',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Akcje',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(child: Text('Brak pracowników'))
                : ListView(
                    children: [
                      for (final groupName in groupNames) ...[
                        Container(
                          color: Colors.grey[100],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            '$groupName (${groupedEmployees[groupName]!.length})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...groupedEmployees[groupName]!.map(
                          (employee) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(employee.employeeNumber),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(employee.name),
                                    ),
                                    Expanded(flex: 2, child: Text(groupName)),
                                    Expanded(
                                      flex: 2,
                                      child: Text(employee.position),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(employee.department),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        employee.email,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                            ),
                                            onPressed: () => _showEmployeeForm(
                                              employee: employee,
                                            ),
                                            tooltip: 'Edytuj',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _deleteEmployee(employee.id),
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
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
