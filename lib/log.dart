import 'dart:convert';

class Log {
  String id;
  String user_id;
  String station_id;
  String charger_id;
  String charge_bill;
  String charge_time;
  String charging_mode;
  String start_time;
  Log({
    required this.id,
    required this.user_id,
    required this.station_id,
    required this.charger_id,
    required this.charge_bill,
    required this.charge_time,
    required this.charging_mode,
    required this.start_time,
  });

  Log copyWith({
    String? id,
    String? user_id,
    String? station_id,
    String? charger_id,
    String? charge_bill,
    String? charge_time,
    String? charging_mode,
    String? start_time,
  }) {
    return Log(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      station_id: station_id ?? this.station_id,
      charger_id: charger_id ?? this.charger_id,
      charge_bill: charge_bill ?? this.charge_bill,
      charge_time: charge_time ?? this.charge_time,
      charging_mode: charging_mode ?? this.charging_mode,
      start_time: start_time ?? this.start_time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'station_id': station_id,
      'charger_id': charger_id,
      'charge_bill': charge_bill,
      'charge_time': charge_time,
      'charging_mode': charging_mode,
      'start_time': start_time,
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'] as String,
      user_id: map['user_id'] as String,
      station_id: map['station_id'] as String,
      charger_id: map['charger_id'] as String,
      charge_bill: map['charge_bill'] as String,
      charge_time: map['charge_time'] as String,
      charging_mode: map['charging_mode'] as String,
      start_time: map['start_time'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Log.fromJson(String source) => Log.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Log(id: $id, user_id: $user_id, station_id: $station_id, charger_id: $charger_id, charge_bill: $charge_bill, charge_time: $charge_time, charging_mode: $charging_mode, start_time: $start_time)';
  }

  @override
  bool operator ==(covariant Log other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user_id == user_id &&
        other.station_id == station_id &&
        other.charger_id == charger_id &&
        other.charge_bill == charge_bill &&
        other.charge_time == charge_time &&
        other.charging_mode == charging_mode &&
        other.start_time == start_time;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user_id.hashCode ^
        station_id.hashCode ^
        charger_id.hashCode ^
        charge_bill.hashCode ^
        charge_time.hashCode ^
        charging_mode.hashCode ^
        start_time.hashCode;
  }
}
