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

  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  static set instance(FirebaseService service) => _instance = service;

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

  /// Maps Cloud Firestore exceptions to user-friendly messages.
  static String firestoreMessage(Object e) {
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') {
        return 'Access denied: Cloud Firestore security rules in your Firebase Console are blocking access. Update your Firestore rules to allow authenticated users.';
      } else if (e.code == 'unavailable') {
        return 'Network unavailable. Please check your internet connection.';
      }
      return e.message ?? e.code;
    }
    return e.toString();
  }

  // ───────── DEVICES ─────────
  /// Dashboard list (live), memory sorted to avoid composite index requirements.
  Stream<List<Device>> watchDevices() {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return const Stream.empty();
    return _devices
        .where('ownerUid', isEqualTo: currentUid)
        .snapshots()
        .map((s) {
          final list = s.docs.map(Device.fromDoc).toList();
          list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return list;
        });
  }

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
      .snapshots()
      .map((s) {
        if (s.docs.isEmpty) return null;
        final list = s.docs.map(Measurement.fromDoc).toList()
          ..sort((a, b) => b.sampledAt.compareTo(a.sampledAt));
        return list.firstOrNull;
      });

  /// Samples of one device since [since], oldest first. Bad sensor reads removed.
  Future<List<Measurement>> history(String deviceId, DateTime since, {int? limit}) async {
    try {
      final snap = await _measurements
          .where('deviceId', isEqualTo: deviceId)
          .get()
          .timeout(const Duration(seconds: 5));
      final items = snap.docs
          .map(Measurement.fromDoc)
          .where((m) =>
              m.isPlausible &&
              (m.sampledAt.isAfter(since) || m.sampledAt.isAtSameMomentAs(since)))
          .toList()
        ..sort((a, b) => a.sampledAt.compareTo(b.sampledAt));
      if (limit != null && items.length > limit) {
        return items.sublist(items.length - limit);
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  /// Samples from ALL of the user's devices since [since] (for aggregates).
  Future<List<Measurement>> historyAllDevices(DateTime since) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return [];
    try {
      final snap = await _measurements
          .where('ownerUid', isEqualTo: currentUid)
          .get()
          .timeout(const Duration(seconds: 5));
      return snap.docs
          .map(Measurement.fromDoc)
          .where((m) =>
              m.isPlausible &&
              (m.sampledAt.isAfter(since) || m.sampledAt.isAtSameMomentAs(since)))
          .toList()
        ..sort((a, b) => a.sampledAt.compareTo(b.sampledAt));
    } catch (_) {
      return [];
    }
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
      .snapshots()
      .map((s) {
        final list = s.docs.map(Command.fromDoc).toList();
        list.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        return list.take(limit).toList();
      });

  /// Only allowed while the command is still pending.
  Future<void> cancelCommand(String commandId) =>
      _commands.doc(commandId).update({'status': CommandStatus.cancelled.name});
}
