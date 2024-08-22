import 'package:flutter/material.dart';
import 'package:fauna_prototype/services/navigation.dart';
import 'package:provider/provider.dart';

class MedPage extends StatelessWidget {
  MedPage({super.key});
  final TextEditingController _controller = TextEditingController();
  final Image brunoImage = const Image(image: AssetImage('assets/images/bruno.png'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bruno'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<NavigationService>(context, listen: false).goHome();
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 42, 58, 47),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 500, child: brunoImage),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                
                fillColor: Color.fromARGB(255, 62, 78, 67),
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
                   Provider.of<NavigationService>(context, listen: false).goProcrastination();
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