class AgentData {
  final String name;
  final String instruction;
  final List<Map<String, Object>> tools;

  AgentData({
    required this.name,
    required this.instruction,
    required this.tools,
  });

  // From JSON
  factory AgentData.fromJson(Map<String, dynamic> json) {
    return AgentData(
      name: json['name'],
      instruction: json['instruction'],
      tools: (json['tools'] as List<dynamic>?)?.map((tool) => Map<String, Object>.from(tool)).toList() ?? [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'instruction': instruction,
      'tools': tools,
    };
  }
}