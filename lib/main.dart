import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'api.dart';
import 'demo_data.dart';

const ink = Color(0xFF14233B),
    navy = Color(0xFF10213A),
    blue = Color(0xFF3667E8),
    mint = Color(0xFF12A982),
    paper = Color(0xFFF5F7FB);
final beaconId = UUID.short(0xFDF0);
void main() => runApp(const ProxyProofApp());

class ProxyProofApp extends StatelessWidget {
  const ProxyProofApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ProxyProof',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: blue),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.1,
        ),
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(color: Color(0xFF637089), height: 1.4),
      ),
    ),
    home: const LoginPage(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>(),
      email = TextEditingController(),
      password = TextEditingController();
  DemoRole role = DemoRole.student;
  bool busy = false, hide = true;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!(form.currentState?.validate() ?? false)) return;
    setState(() => busy = true);
    try {
      final u = await Api.instance.login(
        email.text.trim(),
        password.text,
        role == DemoRole.teacher ? 'teacher' : 'student',
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => role == DemoRole.teacher
              ? FacultyPage(user: u)
              : StudentPage(user: u),
        ),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [navy, Color(0xFF253E67)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bluetooth, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'ProxyProof',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFF9BE9CD),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Attendance, verified.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue to your classroom.',
                        style: TextStyle(color: Color(0xFFD5DEED)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Continue as',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<DemoRole>(
                          segments: const [
                            ButtonSegment(
                              value: DemoRole.student,
                              label: Text('Student'),
                              icon: Icon(Icons.school_outlined),
                            ),
                            ButtonSegment(
                              value: DemoRole.teacher,
                              label: Text('Faculty'),
                              icon: Icon(Icons.co_present_outlined),
                            ),
                          ],
                          selected: {role},
                          onSelectionChanged: (v) =>
                              setState(() => role = v.first),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Enter a valid email address'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: password,
                          obscureText: hide,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hide = !hide),
                              icon: Icon(
                                hide
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter your password'
                              : null,
                          onFieldSubmitted: (_) => login(),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: busy ? null : login,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: busy
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Demo password: demo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF718099),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => setState(() {
                                role = DemoRole.teacher;
                                email.text = DemoDatabase.teachers.first.email;
                              }),
                              child: const Text('Faculty account'),
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                role = DemoRole.student;
                                email.text = DemoDatabase.students.first.email;
                              }),
                              child: const Text('Student account'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Local service · SQLite records · rotating Bluetooth check-in',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8A94A7), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class FacultyPage extends StatefulWidget {
  const FacultyPage({super.key, required this.user});
  final Map<String, dynamic> user;
  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  final peripheral = PeripheralManager();
  Timer? rotate, refresh;
  StreamSubscription? eventSub;
  String? sessionId, sessionName;
  String status = 'No active session';
  String? error;
  List<dynamic> students = [];
  bool busy = false;
  bool rotatingToken = false;
  bool loadingRoster = false;
  bool broadcasting = false;
  bool sessionClosed = false;
  int expiresAt = 0;
  Future<void> start() async {
    setState(() => busy = true);
    try {
      final s = await Api.instance.request(
        'POST',
        '/sessions',
        data: {
          'className': 'Computer Networks',
          'room': 'B204',
          'durationMinutes': 5,
        },
      );
      sessionId = s['id'];
      sessionName = s['className'];
      sessionClosed = false;
      refresh = Timer.periodic(const Duration(seconds: 2), (_) => _roster());
      await _roster();
      await _startBroadcast();
    } catch (e) {
      if (mounted) {
        setState(() {
          if (sessionId != null) status = 'Broadcast paused';
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _startBroadcast() async {
    if (Platform.isAndroid) {
      final authorized = await peripheral.authorize();
      if (!authorized) {
        throw Exception(
          'Bluetooth permission was denied. Allow Nearby devices and try again.',
        );
      }
    }
    if (peripheral.state == BluetoothLowEnergyState.poweredOff) {
      throw Exception('Turn on Bluetooth, then retry the broadcast.');
    }
    if (peripheral.state == BluetoothLowEnergyState.unsupported) {
      throw Exception('This phone does not support BLE advertising.');
    }
    if (await _rotateToken()) {
      rotate?.cancel();
      rotate = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _rotateToken(),
      );
    }
  }

  Future<void> retryBroadcast() async {
    if (sessionId == null || sessionClosed || busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await _startBroadcast();
    } catch (e) {
      if (mounted) {
        setState(() {
          broadcasting = false;
          status = 'Broadcast paused';
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool> _rotateToken() async {
    if (sessionId == null || sessionClosed || rotatingToken) {
      return broadcasting;
    }
    rotatingToken = true;
    final bytes = List<int>.generate(11, (_) => Random.secure().nextInt(256));
    final token = base64Url.encode(bytes).replaceAll('=', '');
    try {
      await Api.instance.request(
        'POST',
        '/sessions/$sessionId/token',
        data: {'token': token},
      );
      await peripheral.stopAdvertising();
      await peripheral.startAdvertising(
        Advertisement(
          serviceData: {
            beaconId: Uint8List.fromList(utf8.encode('$sessionId:$token')),
          },
        ),
      );
      broadcasting = true;
      if (mounted) {
        setState(() {
          status = 'Broadcasting · rotating code every 5 sec';
          error = null;
        });
      }
      return true;
    } catch (e) {
      broadcasting = false;
      rotate?.cancel();
      try {
        await peripheral.stopAdvertising();
      } catch (_) {}
      if (mounted) {
        setState(() {
          status = 'Broadcast paused';
          error = 'Bluetooth broadcast failed: $e';
        });
      }
      return false;
    } finally {
      rotatingToken = false;
    }
  }

  Future<void> _roster() async {
    if (sessionId == null || loadingRoster) return;
    loadingRoster = true;
    try {
      final r = await Api.instance.request(
        'GET',
        '/sessions/$sessionId/attendance',
      );
      if (!mounted) return;
      final sessionEndsAt = r['session']['endsAt'] as int;
      final sessionEnded =
          r['session']['closed'] == true ||
          sessionEndsAt <= DateTime.now().millisecondsSinceEpoch;
      setState(() {
        students = r['students'] as List<dynamic>;
        expiresAt = sessionEndsAt;
        sessionClosed = sessionEnded;
        if (sessionEnded) status = 'Session closed';
      });
      if (sessionEnded) {
        rotate?.cancel();
        refresh?.cancel();
        if (broadcasting) {
          broadcasting = false;
          try {
            await peripheral.stopAdvertising();
          } catch (_) {}
        }
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      loadingRoster = false;
    }
  }

  Future<void> closeSession() async {
    if (sessionId == null) return;
    rotate?.cancel();
    refresh?.cancel();
    broadcasting = false;
    Object? stopError;
    try {
      await peripheral.stopAdvertising();
    } catch (e) {
      stopError = e;
    }
    try {
      await Api.instance.request('POST', '/sessions/$sessionId/close');
      if (mounted) {
        setState(() {
          status = 'Session closed';
          sessionClosed = true;
          error = stopError == null
              ? null
              : 'Bluetooth stop failed: $stopError';
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> manual(dynamic student, bool present) async {
    try {
      await Api.instance.request(
        'POST',
        '/sessions/manual-attendance',
        data: {
          'sessionId': sessionId,
          'studentId': student['id'],
          'present': present,
        },
      );
      await _roster();
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  void dispose() {
    rotate?.cancel();
    refresh?.cancel();
    peripheral.stopAdvertising();
    eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final present = students.where((s) => s['marked_at'] != null).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProxyProof · Faculty'),
        actions: [
          IconButton(
            tooltip: 'Approve device changes',
            onPressed: () => showDeviceRequests(context),
            icon: const Icon(Icons.phonelink_setup),
          ),
          IconButton(
            onPressed: () => showHistory(context),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Hello, ${widget.user['name']}',
            style: const TextStyle(color: Color(0xFF718099)),
          ),
          const SizedBox(height: 8),
          Text(
            sessionId == null ? 'Classroom' : 'Live attendance',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionName ?? 'Ready to start class',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sessionId == null
                      ? 'B204 · 5 minute attendance session'
                      : 'Room B204 · session ${sessionId!.substring(0, 8)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _metric('$present', 'PRESENT'),
                    _metric('${students.length}', 'ENROLLED'),
                    _metric(
                      sessionId == null ? '—' : _remaining(),
                      'TIME LEFT',
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(status, style: const TextStyle(color: Color(0xFF9BE9CD))),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Color(0xFFFFB5A8)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (sessionId == null)
            FilledButton.icon(
              onPressed: busy ? null : start,
              icon: const Icon(Icons.bluetooth_audio),
              label: Text(busy ? 'Starting…' : 'Start 5 minute session'),
            )
          else ...[
            if (!broadcasting && !sessionClosed)
              FilledButton.icon(
                onPressed: busy ? null : retryBroadcast,
                icon: const Icon(Icons.bluetooth_searching),
                label: Text(busy ? 'Retrying…' : 'Retry Bluetooth broadcast'),
              ),
            if (!broadcasting && !sessionClosed) const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Enrolled students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => exportCsv(context),
                  icon: const Icon(Icons.download),
                  label: const Text('CSV'),
                ),
              ],
            ),
            ...students.map((s) {
              final present = s['marked_at'] != null;
              return Card(
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(child: Text(_initials(s['name']))),
                  title: Text(s['name']),
                  subtitle: Text(
                    present
                        ? '${s['source'] == 'ble' ? 'Bluetooth check-in' : 'Manually marked'} · ${DateTime.fromMillisecondsSinceEpoch(s['marked_at']).toLocal().toString().substring(11, 16)}'
                        : 'Not checked in',
                  ),
                  trailing: present
                      ? IconButton(
                          tooltip: 'Remove attendance',
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: () => manual(s, false),
                        )
                      : IconButton(
                          tooltip: 'Mark present',
                          icon: const Icon(Icons.person_add_alt_1),
                          onPressed: () => manual(s, true),
                        ),
                ),
              );
            }),
            FilledButton.tonalIcon(
              onPressed: closeSession,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Close session'),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'The server accepts a fresh session code only from an enrolled account and registered phone, with a strong nearby signal.',
            style: TextStyle(color: Color(0xFF718099), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _remaining() {
    final seconds = max(
      0,
      (expiresAt - DateTime.now().millisecondsSinceEpoch) ~/ 1000,
    );
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _metric(String v, String label) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          v,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key, required this.user});
  final Map<String, dynamic> user;
  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final central = CentralManager();
  StreamSubscription? sub;
  Timer? liveClassRefresh;
  bool scanning = false, busy = false, checked = false;
  bool loadingLiveClasses = false;
  final checkedSessionIds = <String>{};
  String? scanningSessionId;
  String message = 'Bluetooth scan is off';
  String? checkedClass;
  List<dynamic> liveClasses = [];
  String? liveClassesError;
  List<dynamic> attendance = [];
  int attendancePercent = 0;
  int completedSessions = 0;
  int attendedSessions = 0;
  final seen = <String>{};
  Future<void> scan() async {
    try {
      if (Platform.isAndroid) {
        final authorized = await central.authorize();
        if (!authorized) {
          throw Exception(
            'Bluetooth scan permission was denied. Allow Nearby devices and retry.',
          );
        }
        if (central.state == BluetoothLowEnergyState.poweredOff) {
          throw Exception('Turn on Bluetooth, then restart check-in.');
        }
        if (central.state == BluetoothLowEnergyState.unsupported) {
          throw Exception('This phone does not support Bluetooth LE scanning.');
        }
      }
      await sub?.cancel();
      sub = central.discovered.listen(_found);
      await central.startDiscovery();
      if (mounted) {
        setState(() {
          scanning = true;
          message = 'Scanning for an active class…';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          scanning = false;
          message = 'Bluetooth permission or adapter issue: $e';
        });
      }
    }
  }

  Future<void> _found(DiscoveredEventArgs e) async {
    if (busy || checked) return;
    final raw = e.advertisement.serviceData[beaconId];
    if (raw == null) return;
    final payload = utf8.decode(raw, allowMalformed: true).split(':');
    if (payload.length != 2 || payload[0].length != 8 || !seen.add(payload[0]))
      return;
    if (scanningSessionId != null && payload[0] != scanningSessionId) {
      seen.remove(payload[0]);
      return;
    }
    busy = true;
    try {
      await Api.instance.request(
        'POST',
        '/check-in',
        data: {
          'sessionId': payload[0],
          'token': payload[1],
          'rssi': e.rssi,
          'deviceId': await Api.instance.deviceId,
        },
      );
      await central.stopDiscovery();
      await sub?.cancel();
      final matchedClass = liveClasses.where(
        (session) => session['id'] == payload[0],
      );
      if (mounted)
        setState(() {
          checked = true;
          checkedSessionIds.add(payload[0]);
          scanning = false;
          checkedClass = matchedClass.isEmpty
              ? 'Attendance confirmed'
              : 'Checked in to ${matchedClass.first['className']}';
          message = 'You are checked in.';
        });
      _loadHistory();
      _loadLiveClasses();
    } catch (e) {
      seen.remove(payload[0]);
      if (mounted)
        setState(() => message = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      busy = false;
    }
  }

  Future<void> restartCheckIn(dynamic session) async {
    final sessionId = session['id'] as String;
    setState(() => busy = true);
    try {
      await central.stopDiscovery();
      await sub?.cancel();
      seen.clear();
      scanningSessionId = sessionId;
      setState(() {
        checked = false;
        scanning = false;
        checkedClass = null;
        message = 'Restarting Bluetooth check-in…';
      });
      await scan();
    } catch (e) {
      if (mounted) {
        setState(() {
          scanning = false;
          message = 'Could not restart Bluetooth check-in: $e';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    scan();
    _loadHistory();
    _loadLiveClasses();
    liveClassRefresh = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _loadLiveClasses(),
    );
  }

  Future<void> _loadLiveClasses() async {
    if (loadingLiveClasses) return;
    loadingLiveClasses = true;
    try {
      final result = await Api.instance.request('GET', '/sessions/active');
      if (!mounted) return;
      setState(() {
        liveClasses = result['sessions'] as List<dynamic>;
        liveClassesError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          liveClassesError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      loadingLiveClasses = false;
    }
  }

  Future<void> _loadHistory() async {
    try {
      final result = await Api.instance.request('GET', '/my-attendance');
      if (!mounted) return;
      setState(() {
        attendance = result['attendance'] as List<dynamic>;
        attendancePercent = result['percentage'] as int;
        completedSessions = result['totalSessions'] as int;
        attendedSessions = result['attendedSessions'] as int;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    central.stopDiscovery();
    sub?.cancel();
    liveClassRefresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('ProxyProof · Student'),
      actions: [
        IconButton(
          onPressed: () => logout(context),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'STUDENT',
          style: TextStyle(
            color: blue,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You’re all set,\n${widget.user['name']}.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        const Text(
          'Keep Bluetooth on near your classroom. On Android 11 or earlier, turn on Location too. Attendance is checked against the rotating live session code.',
          style: TextStyle(fontSize: 15, color: Color(0xFF637089)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Live classes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Refresh live classes',
              onPressed: _loadLiveClasses,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (liveClasses.isEmpty)
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_busy_outlined,
                    color: Color(0xFF718099),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      liveClassesError != null
                          ? 'Could not load live classes: $liveClassesError'
                          : scanning
                          ? 'No live classes yet. This list updates automatically.'
                          : 'No live classes found. Start scanning again to check in nearby.',
                      style: const TextStyle(color: Color(0xFF637089)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...liveClasses.map((session) {
            final endsAt = DateTime.fromMillisecondsSinceEpoch(
              session['endsAt'] as int,
            );
            final remaining = endsAt.difference(DateTime.now());
            final minutes = remaining.inMinutes;
            final seconds = remaining.inSeconds
                .remainder(60)
                .toString()
                .padLeft(2, '0');
            final isCheckedIn = checkedSessionIds.contains(session['id']);
            return Card(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE4F8F1),
                      child: Icon(Icons.sensors_rounded, color: mint),
                    ),
                    title: Text(
                      session['className'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${session['room']} · ${session['facultyName']}\nBluetooth check-in runs automatically when you are nearby.',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      remaining.isNegative
                          ? 'Ending'
                          : '${minutes}m ${seconds}s',
                      style: const TextStyle(
                        color: blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isCheckedIn)
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            color: mint,
                            size: 18,
                          ),
                          label: Text('PRESENT'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.how_to_reg_outlined),
                          label: Text(
                            busy ? 'Restarting check-in…' : 'Restart check-in',
                          ),
                          onPressed: busy || remaining.isNegative
                              ? null
                              : () => restartCheckIn(session),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: checked
                    ? const Color(0xFFE4F8F1)
                    : const Color(0xFFEAF0FF),
                child: Icon(
                  checked ? Icons.verified_rounded : Icons.bluetooth_searching,
                  color: checked ? mint : blue,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                checked ? 'You’re checked in' : 'Looking for your class',
                style: const TextStyle(
                  color: ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                checkedClass ?? message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF718099)),
              ),
              const SizedBox(height: 16),
              if (checked)
                const Chip(
                  label: Text('PRESENT'),
                  avatar: Icon(Icons.check_circle, color: mint),
                )
              else if (!scanning)
                FilledButton.icon(
                  onPressed: scan,
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text('Scan again'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Attendance history',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Text('$attendancePercent%'),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$attendancePercent% attendance · $attendedSessions marks across $completedSessions completed sessions',
                ),
                const SizedBox(height: 8),
                if (attendance.isEmpty)
                  const Text('No attendance records yet.')
                else
                  ...attendance
                      .take(5)
                      .map(
                        (row) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(row['class_name']),
                          subtitle: Text(
                            '${row['room']} · ${DateTime.fromMillisecondsSinceEpoch(row['started_at']).toLocal()}',
                          ),
                          trailing: const Icon(
                            Icons.check_circle,
                            color: mint,
                            size: 18,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'DEVICE BINDING',
          style: TextStyle(
            color: Color(0xFF8A94A7),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        const Card(
          color: Colors.white,
          child: ListTile(
            leading: Icon(Icons.phonelink_lock, color: blue),
            title: Text('This phone is registered'),
            subtitle: Text(
              'A faculty approval is required to move your account to another phone.',
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> showHistory(BuildContext context) async {
  try {
    final r = await Api.instance.request('GET', '/sessions/history');
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Attendance history',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...(r['sessions'] as List).map(
              (s) => ListTile(
                title: Text(s['class_name']),
                subtitle: Text(
                  '${s['room']} · ${DateTime.fromMillisecondsSinceEpoch(s['started_at']).toLocal()}',
                ),
                trailing: Text('${s['present']} present'),
              ),
            ),
            TextButton.icon(
              onPressed: () => exportCsv(ctx),
              icon: const Icon(Icons.download),
              label: const Text('Download CSV'),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    if (context.mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

Future<void> exportCsv(BuildContext context) async {
  try {
    final r = await Api.instance.request('GET', '/sessions/history?format=csv');
    await SharePlus.instance.share(
      ShareParams(
        title: 'ProxyProof attendance export',
        subject: 'Attendance history',
        files: [
          XFile.fromData(
            utf8.encode(r['body']?.toString() ?? ''),
            name: 'proxyproof-attendance.csv',
            mimeType: 'text/csv',
          ),
        ],
      ),
    );
  } catch (e) {
    if (context.mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

Future<void> showDeviceRequests(BuildContext context) async {
  try {
    final result = await Api.instance.request('GET', '/device-requests');
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Device change requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if ((result['requests'] as List).isEmpty)
              const ListTile(title: Text('No pending requests')),
            ...(result['requests'] as List).map(
              (request) => ListTile(
                title: Text(request['name']),
                subtitle: Text(request['email']),
                trailing: FilledButton(
                  onPressed: () async {
                    try {
                      await Api.instance.request(
                        'POST',
                        '/device-requests/${request['id']}/approve',
                      );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      if (context.mounted) showDeviceRequests(context);
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: const Text('Approve'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    if (context.mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

void logout(BuildContext context) {
  Api.instance.token = null;
  Api.instance.user = null;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (_) => false,
  );
}

String _initials(String name) =>
    name.split(' ').map((e) => e[0]).take(2).join();
