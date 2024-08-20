import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fauna_prototype/services/agentservice.dart';

class BuddyService extends AgentService {
  BuddyService() : super();
  String tmp = '';

  @override
  Future<String> createAssistant() async {
    final body = jsonEncode({
      'instructions': "Your name is Buddy.",
      'name': "Buddy",
      'model': "gpt-4o-mini",
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/assistants'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print("success to create buddy.");
      final data = jsonDecode(response.body);
      return data['id'] as String;
    } else {
      throw Exception('Failed to create assistant');
    }
  }

  Future<void> fetchPromptResponse(String prompt) async {
    
    // 1. Post prompt to the thread
    var promptResponse = await http.post(
      Uri.parse(messagesUrl),
      headers: headers,
      body: jsonEncode({
        'role': 'user',
        'content': prompt,
      }),
    );
    // Check if the prompt was successfully added
    if (promptResponse.statusCode != 200) {
      throw Exception('Failed to add prompt: ${promptResponse.statusCode}');
    }

    // 2. Creating a run to generate a response
    var runResponse = await http.post(
      Uri.parse(runsUrl),
      headers: headers,
      body: jsonEncode({
        'assistant_id': assistantId,
        // Additional instructions can be passed here if needed
      }),
    );
    // Check if run was successfully created
    if (runResponse.statusCode != 200) {
      throw Exception('Failed to create a run: ${runResponse.statusCode}');
    }
    
    // 3. Wait for the run to complete
    var runData = json.decode(runResponse.body);
    var runId = runData['id'];
    String runStatusUrl = '$baseUrl/threads/$threadId/runs/$runId';
    while (true) {
      // Wait for a short period before checking again
      await Future.delayed(Duration(seconds: 2));

      var runStatusResponse = await http.get(
        Uri.parse(runStatusUrl),
        headers: headers,
      );
      if (runStatusResponse.statusCode != 200) {
        throw Exception(
            'Failed to query run status: ${runStatusResponse.statusCode}');
      }
      var runStatusData = json.decode(runStatusResponse.body);
      var runStatus = runStatusData['status'];
      if (runStatus == 'cancelled' ||
          runStatus == 'failed' ||
          runStatus == 'expired') {
        throw Exception('Run failed: ${runStatusData['status']}');
      }
      // Indicate that Function Calling is used (see: https://platform.openai.com/docs/assistants/tools/function-calling)
      if (runStatus == 'requires_action') {
        var toolCallID = runStatusData['required_action']['submit_tool_outputs']['tool_calls'][0]['id'];
        final _submitUrl = 'https://api.openai.com/v1/threads/$threadId/runs/$runId/submit_tool_outputs'; 
        var submitResponse = await http.post(
          Uri.parse(_submitUrl),
          headers: headers,
          body: jsonEncode({
            'tool_outputs': [
              {
                'tool_call_id': toolCallID,
                'output': 'bad',
              },
            ],
          }),
        );
      }
      if (runStatus == 'completed') {
        break;
      }
    }
    
    var response = await http.get(
      Uri.parse(messagesUrl),
      headers: headers,
    );
    

    // Check if messages were successfully fetched
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch messages: ${response.statusCode}');
    }

    var responseData = json.decode(utf8.decode(response.bodyBytes));
    print(responseData['data'][0]['content'][0]['text']['value']);
    tmp = responseData['data'][0]['content'][0]['text']['value'];
  }
}
