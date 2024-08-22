import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fauna_prototype/services/agentservice.dart';

class BuddyService extends AgentService {
  BuddyService(super. name);
  String agentName = '';
  String toolOutputs = '';
  @override
  Future<String> functionCallAction(dynamic runStatusData, String threadId, String runId) async {
    var toolCallID = runStatusData['required_action']['submit_tool_outputs']['tool_calls'][0]['id'];
    var function = runStatusData['required_action']['submit_tool_outputs']['tool_calls'][0]['function'];
    var arguments = jsonDecode(function['arguments']);
    //tmp = jsonDecode(runStatusData['required_action']['submit_tool_outputs']['tool_calls'][0]['function']['arguments'])['name'];
    print(function);
    if(function['name'] == 'change_agent'){
      agentName = arguments['name'];
      toolOutputs = "Ask user if they want $agentName to help them.";
    }
    if(function['name'] == 'confirm'){
      if(arguments['answer'] == 'yes'){
        agentName = arguments['name'];
        toolOutputs = "return only $agentName (DO NOT RETURN OTHER WORDS.)";
      }
      else{
        toolOutputs = "user didn't want to speak with $agentName";
      }
    }
    final _submitUrl = 'https://api.openai.com/v1/threads/$threadId/runs/$runId/submit_tool_outputs'; 
    var submitResponse = await http.post(
      Uri.parse(_submitUrl),
      headers: headers,
      body: jsonEncode({
        'tool_outputs': [
          {
            'tool_call_id': toolCallID,
            'output': toolOutputs,
          },
        ],
      }),
    );
    print(toolOutputs);
    return toolOutputs;
  }
}