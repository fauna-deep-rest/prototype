import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:fauna_prototype/models/agent_data.dart';
import 'package:flutter/services.dart' show rootBundle;

abstract class AgentService {
  static const _apiKey = 'sk-Ge2aS91XJ3ldGU8h6oq3lj8ZKFoKgXrT27ci7UehNLT3BlbkFJ3v79jj2DF5zPIK62YeCqOOtzTSO_qxnaq9oawQFqUA';
  static const String _baseUrl = 'https://api.openai.com/v1';

  late String _assistantId;
  late String _threadId;
  late String _runId;

  String _messagesUrl;
  String _runsUrl;
  final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'OpenAI-Beta': 'assistants=v2', 
        };

  String tmp = '';

  AgentService(String name) : _messagesUrl = '', _runsUrl = ''{
    _initializeAsync(name);
  }
  
  Future<AgentData> loadAgentData(String name) async {
    final String response = await rootBundle.loadString('assets/$name.json');
    final data = jsonDecode(response);
    return AgentData.fromJson(data);
  }

  // Future<void> _initializeAsync() async {
  //   try {
  //     _threadId = await createThread();
  //       _assistantId = await createAssistant();
  //       print("threadId: " + _threadId);
  //       print("assistantId: " + _assistantId);
  //     _runsUrl = '$_baseUrl/threads/$_threadId/runs';
  //     _messagesUrl = '$_baseUrl/threads/$_threadId/messages';
  //     print("Finished initializing");
  //   } catch (e) {
  //     print('Error initializing AgentService: $e');
  //   }

  // }

  Future<void> _initializeAsync(String name) async {
    print("intializing AgentService");

    AgentData agentdata =  await loadAgentData(name);
    try {
      _threadId = html.window.localStorage['threadId'] ?? '';
      _assistantId = html.window.localStorage['assistantId'] ?? '';

      if (_threadId.isEmpty || _assistantId.isEmpty) {
        // Thread and assistant not found, create new ones
        _threadId = await createThread();
        _assistantId = await createAssistant(name, agentdata.instruction, agentdata.tools);
        html.window.localStorage['threadId'] = _threadId;
        html.window.localStorage['assistantId'] = _assistantId;
      }

      print("threadId: " + _threadId);
      print("assistantId: " + _assistantId);
      _runsUrl = '$_baseUrl/threads/$_threadId/runs';
      _messagesUrl = '$_baseUrl/threads/$_threadId/messages';

      print("Finished initializing");
    } catch (e) {
      print('Error initializing AgentService: $e');
    }
  }

  Future<String> createThread() async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/threads'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'OpenAI-Beta': 'assistants=v2',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'] as String;
    } else {
      throw Exception('Failed to create thread');
    }
  }

  Future<String> createAssistant(String name, String instruction, List<Map<String, Object>> tools) async{
    final body = jsonEncode({
      'instructions': instruction,
      'name': name,
      'model': "gpt-4o-mini",
      'tools': tools,
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

  Future<void> createRun() async {
    final body = jsonEncode({
      'assistant_id': _assistantId,
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/threads/$_threadId/runs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'OpenAI-Beta': 'assistants=v2',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create run');
    }
  }

  Future<String> fetchPromptResponse(String prompt) async {
    // 1. Post prompt to the thread
    var promptResponse = await http.post(
      Uri.parse(_messagesUrl),
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
      Uri.parse(_runsUrl),
      headers: headers,
      body: jsonEncode({
        'assistant_id': _assistantId,
        // Additional instructions can be passed here if needed
      }),
    );
    // Check if run was successfully created
    if (runResponse.statusCode != 200) {
      throw Exception('Failed to create a run: ${runResponse.statusCode}');
    }
    
    // 3. Wait for the run to complete
    var runData = jsonDecode(runResponse.body);
    _runId = runData['id'];
    String runStatusUrl = '$_baseUrl/threads/$_threadId/runs/$_runId';
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
        var actionResponse = await functionCallAction(runStatusData, _threadId, _runId);
        if(actionResponse != 'No action required') return actionResponse;
      }
      if (runStatus == 'completed') {
        break;
      }
    }
    
    var response = await http.get(
      Uri.parse(_messagesUrl),
      headers: headers,
    );
    

    // Check if messages were successfully fetched
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch messages: ${response.statusCode}');
    }

    var responseData = json.decode(utf8.decode(response.bodyBytes));
    print(responseData['data'][0]['content'][0]['text']['value']);
    tmp = responseData['data'][0]['content'][0]['text']['value'];

    return tmp;
  }

  Future<String> functionCallAction(dynamic runStatusData, String threadId, String runId);
}