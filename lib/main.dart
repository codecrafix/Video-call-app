import 'package:flutter/material.dart';
import 'call_screen.dart';
import 'config.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _channelCtrl =
      TextEditingController(text: defaultChannelName);
  final TextEditingController _tokenCtrl =
      TextEditingController(text: defaultAgoraToken);

  @override
  void dispose() {
    _channelCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  void _start(String gender) {
    final channel = _channelCtrl.text.trim();
    if (channel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel name khali nahi ho sakta')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          gender: gender,
          channel: channel,
          token: _tokenCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                  'Dono phone me same Channel name aur same Token rakho',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _channelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Channel name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Agora Token (Certificate ON ho to paste karo)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: () => _start('Male'),
                    icon: const Icon(Icons.male),
                    label: const Text('Male', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: () => _start('Female'),
                    icon: const Icon(Icons.female),
                    label: const Text('Female', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
