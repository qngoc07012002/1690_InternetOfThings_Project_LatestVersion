class Slot{
  final String? slotID;
  final String? slotName;
  final String? timeIn;
  final String? timeOut;

  Slot({this.slotID, this.slotName, this.timeIn, this.timeOut});

  factory Slot.fromJson(Map<String, dynamic> json){
    return Slot(
      slotID: json['SlotID'],
      slotName: json['Name'],
      timeIn: json['TimeIn'],
      timeOut: json['TimeOut']);
  }
}
