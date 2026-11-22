import 'package:aqua_node/core/enums/enums.dart';
import 'package:aqua_node/core/models/command.dart';
import 'package:aqua_node/core/models/device.dart';
import 'package:aqua_node/core/models/masurement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Single entry point for everything the app does with Firebase.
/// Usage: FirebaseService.instance.watchDevices()
class FirebaseService {
  FirebaseService._({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static final FirebaseService instance = FirebaseService._();

  /// For tests (e.g. fake_cloud_firestore / emulator).
  factory FirebaseService.forTesting({required FirebaseFirestore db, required FirebaseAuth auth}) =>
      FirebaseService._(db: db, auth: auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _devices => _db.collection('devices');
  CollectionReference<Map<String, dynamic>> get _measurements => _db.collection('measurements');
  CollectionReference<Map<String, dynamic>> get _commands => _db.collection('commands');

  // ───────── AUTH ─────────
  Stream<User?> get authState => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String get uid {
    final u = _auth.currentUser;
    if (u == null) throw StateError('Not signed in');
    return u.uid;
  }

  get Timestamp => null;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);
  Future<void> signOut() => _auth.signOut();

  /// Maps FirebaseAuthException codes to messages for the sign-in form.
  static String authMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email': return 'Enter a valid email address.';
        case 'user-disabled': return 'This account is disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential': return 'Incorrect email or password.';
        case 'too-many-requests': return 'Too many attempts. Try again later.';
        case 'network-request-failed': return 'No connection. Check your network.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  // ───────── DEVICES ─────────
  /// Dashboard list (live).
  Stream<List<Device>> watchDevices() => _devices
      .where('ownerUid', isEqualTo: uid)
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs.map(Device.fromDoc).toList());

  /// One device (live).
  Stream<Device?> watchDevice(String deviceId) =>
      _devices.doc(deviceId).snapshots().map((d) => d.exists ? Device.fromDoc(d) : null);

  /// Rename / location / enable-disable.
  Future<void> updateDeviceSettings(String deviceId,
          {required String name, required String locationLabel, required bool isEnabled}) =>
      _devices.doc(deviceId).update(Device.settingsUpdate(name: name, locationLabel: locationLabel, isEnabled: isEnabled));

  // ───────── MEASUREMENTS ─────────
  /// Latest sample of one device (live).
  Stream<Measurement?> watchLatest(String deviceId) => _measurements
      .where('deviceId', isEqualTo: deviceId)
      .orderBy('sampledAt', descending: true)
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isEmpty ? null : Measurement.fromDoc(s.docs.first));

  /// Samples of one device since [since], oldest first. Bad sensor reads removed.
  Future<List<Measurement>> history(String deviceId, DateTime since, {int? limit}) async {
    var q = _measurements
        .where('deviceId', isEqualTo: deviceId)
        .where('sampledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('sampledAt');
    if (limit != null) q = q.limit(limit);
    final snap = await q.get();
    return snap.docs.map(Measurement.fromDoc).where((m) => m.isPlausible).toList();
  }

  /// Samples from ALL of the user's devices since [since] (for aggregates).
  Future<List<Measurement>> historyAllDevices(DateTime since) async {
    final snap = await _measurements
        .where('ownerUid', isEqualTo: uid)
        .where('sampledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('sampledAt')
        .get();
    return snap.docs.map(Measurement.fromDoc).where((m) => m.isPlausible).toList();
  }

  // ───────── COMMANDS ─────────
  /// Creates a pending valve command and returns its ID.
  Future<String> sendValveCommand(String deviceId, CommandAction action) async {
    final ref = await _commands.add(Command.create(deviceId: deviceId, uid: uid, action: action));
    return ref.id;
  }

  /// Live status of one command (pending → received → executed/failed).
  Stream<Command?> watchCommand(String commandId) =>
      _commands.doc(commandId).snapshots().map((d) => d.exists ? Command.fromDoc(d) : null);

  /// Latest commands for a device.
  Stream<List<Command>> watchCommands(String deviceId, {int limit = 20}) => _commands
      .where('deviceId', isEqualTo: deviceId)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(Command.fromDoc).toList());

  /// Only allowed while the command is still pending.
  Future<void> cancelCommand(String commandId) =>
      _commands.doc(commandId).update({'status': CommandStatus.cancelled.name});
}