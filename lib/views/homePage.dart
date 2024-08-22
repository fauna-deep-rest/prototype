import 'package:flutter/material.dart';
import 'package:fauna_prototype/services/navigation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:fauna_prototype/services/agents/buddy.dart';

//import 'package:fauna_prototype/services/chatservice.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState  extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final BuddyService _buddyService = BuddyService("buddy");
  String buddyMessage = 'Hi';

  final Image buddyImage = const Image(image: AssetImage('assets/images/buddy.png'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

          SizedBox(height: 100, child: buddyImage),
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                
                fillColor: Color.fromARGB(255, 50, 50, 50),
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