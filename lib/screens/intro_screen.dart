import 'package:flutter/material.dart';
import 'combat_prep_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.asset('images/bg.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Bem-vindo, Mestre!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Prepare seus dados e organize seu combate.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CombatPrepScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('INICIAR COMBATE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
