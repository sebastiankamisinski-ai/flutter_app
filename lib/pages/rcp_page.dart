import 'package:flutter/material.dart';
import '../models/work_session.dart';
import '../widgets/app_bar.dart';

class RCPPage extends StatefulWidget {
  const RCPPage({super.key});

  @override
  State<RCPPage> createState() => _RCPPageState();
}

class _RCPPageState extends State<RCPPage> {
  bool _isWorking = false;
  DateTime? _workStartTime;
  Duration _totalWorkTime = Duration.zero;
  late DateTime _lastWorkStart;
  final List<WorkSession> _workSessions = [];

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
