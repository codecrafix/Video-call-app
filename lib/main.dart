import 'package:flutter/material.dart';
import 'call_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Call Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _start(BuildContext context, String gender) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CallScreen(gender: gender)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.video_call, size: 80, color: Colors.pink),
              const SizedBox(height: 16),
              const Text(
                'Video Call Test',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apna option chuno aur video call start karo',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 64,
                child: FilledButton.icon(
                  onPressed: () => _start(context, 'Male'),
                  icon: const Icon(Icons.male),
                  label: const Text('Male', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: FilledButton.icon(
                  onPressed: () => _start(context, 'Female'),
                  icon: const Icon(Icons.female),
                  label: const Text('Female', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
