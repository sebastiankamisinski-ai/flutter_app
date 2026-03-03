import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../globals.dart';
import '../widgets/app_bar.dart';

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
