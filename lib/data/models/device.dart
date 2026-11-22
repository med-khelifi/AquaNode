enum Conn { online, offline, never }
enum Verify { verified, pending, failed, unknown }
enum Range { h1, h24, d7 }

extension RangeX on Range {
  String get label => const {Range.h1: '1 hour', Range.h24: '24 hours', Range.d7: '7 days'}[this]!;
  Duration get span => const {Range.h1: Duration(hours: 1), Range.h24: Duration(hours: 24), Range.d7: Duration(days: 7)}[this]!;
  int get bucketMin => const {Range.h1: 1, Range.h24: 10, Range.d7: 60}[this]!;
}

class Device {
  final String id;
  String name, location, firmware;
  bool enabled;
  Conn conn;
  DateTime? lastSeen;
  double temp, hum;
  bool valveOpen; // requested state
  Verify verify;
  Device(this.id, this.name, this.location, this.firmware, this.conn, this.lastSeen,
      {this.temp = 0, this.hum = 0, this.valveOpen = false, this.verify = Verify.unknown, this.enabled = true});
}

class Sample {
  final DateTime t;
  final double temp, hum;
  Sample(this.t, this.temp, this.hum);
}
