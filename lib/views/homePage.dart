import 'package:flutter/material.dart';
import 'package:fauna_prototype/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:fauna_prototype/services/agents/buddy.dart';
import 'package:fauna_prototype/services/chatservice.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState  extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final BuddyService _buddyService = BuddyService();
  String buddyMessage = 'Hi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text('Buddy', style: TextStyle(fontSize: 50))),
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              buddyMessage,
              style: const TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
              softWrap: true,       // 確保文本會自動換行
              maxLines: null,       // 無限制行數
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(30.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Please enter prompt',
              ),
              onSubmitted: (text) async {
                if (text.trim().isNotEmpty) {
                  //Provider.of<NavigationService>(context, listen: false).goProcrastination();
                  print("Sendprompt");
                  var response = await _buddyService.fetchPromptResponse(text);
                  if(response == "bruno"){
                    Provider.of<NavigationService>(context, listen: false).goMeditation();
                  }
                  else if(_buddyService.tmp == "bizy"){
                    Provider.of<NavigationService>(context, listen: false).goProcrastination();
                  }
                  setState(() {
                    buddyMessage = response;  // 更新Buddy的對話內容
                  });  
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