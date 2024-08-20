import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

abstract class AgentService {
  static const _apiKey = 'sk-Ge2aS91XJ3ldGU8h6oq3lj8ZKFoKgXrT27ci7UehNLT3BlbkFJ3v79jj2DF5zPIK62YeCqOOtzTSO_qxnaq9oawQFqUA';
  static const String _baseUrl = 'https://api.openai.com/v1';

  String get baseUrl => _baseUrl;
  late String _assistantId;
  String get assistantId => _assistantId;
  late String _threadId;
  String get threadId => _threadId;

  String _messagesUrl;
  String get messagesUrl => _messagesUrl;
  String _runsUrl;
  String get runsUrl => _runsUrl;
  final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'OpenAI-Beta': 'assistants=v2', 
        };

  AgentService() : _messagesUrl = '', _runsUrl = ''{
    _initializeAsync();
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

    Future<void> _initializeAsync() async {
    print("intializing AgentService");
    try {
      _threadId = html.window.localStorage['threadId'] ?? '';
      _assistantId = html.window.localStorage['assistantId'] ?? '';

      if (_threadId.isEmpty || _assistantId.isEmpty) {
        // Thread and assistant not found, create new ones
        _threadId = await createThread();
        _assistantId = await createAssistant();
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

  Future<String> createAssistant();

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
}