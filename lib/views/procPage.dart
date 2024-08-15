import 'package:flutter/material.dart';
import 'package:fauna_prototype/services/navigation.dart';
import 'package:provider/provider.dart';

class ProcPage extends StatelessWidget {
  ProcPage({super.key});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bizy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<NavigationService>(context, listen: false).goHome();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text('Bizy', style: TextStyle(fontSize: 50))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Please enter prompt',
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                   Provider.of<NavigationService>(context, listen: false).goMeditation();
                  _controller.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid prompt'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}