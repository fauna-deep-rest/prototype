import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fauna_prototype/services/agentservice.dart';

class BuddyService extends AgentService {
  BuddyService(super. name);
  
  submitToolOutput() => "bruno";

  @override
  Future<String> functionCallAction(dynamic runStatusData, String threadId, String runId) async {
    var toolCallID = runStatusData['required_action']['submit_tool_outputs']['tool_calls'][0]['id'];
    tmp = jsonDecode(runStatusData['required_action']['submit_tool_outputs']['tool_calls'][0]['function']['arguments'])['name'];
    final _submitUrl = 'https://api.openai.com/v1/threads/$threadId/runs/$runId/submit_tool_outputs'; 
    var submitResponse = await http.post(
      Uri.parse(_submitUrl),
      headers: headers,
      body: jsonEncode({
        'tool_outputs': [
          {
            'tool_call_id': toolCallID,
            'output': submitToolOutput(),
          },
        ],
      }),
    );
    if(tmp.isNotEmpty) return tmp;
    return 'No action required';
  }
}