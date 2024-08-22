import 'package:flutter/material.dart';
import 'package:fauna_prototype/services/navigation.dart';
import 'package:provider/provider.dart';

class ProcPage extends StatelessWidget {
  ProcPage({super.key});
  final TextEditingController _controller = TextEditingController();
  final Image bizyImage = const Image(image: AssetImage('assets/images/bizy.png'));

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
      backgroundColor: const Color.fromARGB(255, 63, 47, 42),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100, child: bizyImage),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                
                fillColor: Color.fromARGB(255, 83, 67, 62),
                filled: true,
                labelText: 'Please enter prompt',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
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