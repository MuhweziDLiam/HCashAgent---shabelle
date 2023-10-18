class Instruction {
  final String? instructionId;
  final String? instructionDescription;
  final String? instructionImage;
  final String? instructionColor;

  Instruction({
    this.instructionId,
    this.instructionDescription,
    this.instructionImage,
    this.instructionColor,
  });

  factory Instruction.fromjson(Map<String, dynamic> json) {
    final instructionId = json['id'];
    final instructionDescription = json['description'];
    final instructionImage = json['image'];
    final instructionColor = json['color'];

    return Instruction(
      instructionId: instructionId,
      instructionDescription: instructionDescription,
      instructionImage: instructionImage,
      instructionColor: instructionColor,
    );
  }
}

class InstructionList {
  final List<Instruction>? instructionList;

  const InstructionList({
    this.instructionList,
  });

  factory InstructionList.fromJson(List<dynamic> json) {
    final instructionData = json.map((e) => Instruction.fromjson(e)).toList();

    return InstructionList(
      instructionList: instructionData,
    );
  }
}
