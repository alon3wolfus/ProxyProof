# ProxyProof

Flutter app for classroom attendance using rotating Bluetooth Low Energy (BLE) session tokens.

## Build plan

1. **App shell and role flows (current milestone):** role-based sign-in entry, student home/check-in state, organiser live-session dashboard, and history/export entry points. The screens currently use sample data so the navigation and information layout can be reviewed before wiring services.
2. **Identity and device registration:** connect authentication, student/organiser roles, registered-device binding, and the organiser-approved device change flow.
3. **BLE session protocol:** organiser starts a time-bounded session and advertises a signed rotating token; student app scans, validates freshness, and submits the token with its registered device identity. Add platform permission and Bluetooth state handling.
4. **Attendance service:** server validates enrolment, token freshness, device binding, one-device/one-student, and calibrated RSSI proximity; expose live updates to the organiser dashboard.
5. **History and operations:** persist session/attendance records, manual add/remove with audit data, close sessions, and generate CSV exports.
6. **Device and release validation:** test on supported Android phones and rooms, tune proximity thresholds, exercise denied permissions/offline/replay cases, then prepare release builds and privacy disclosures.

## Screen layout

- **Welcome / sign-in:** branded login card, Student or Faculty role selector, validated demo email, password visibility control, autofill support, and quick-fill demo accounts.
- **Student home:** nearby scan state, current class and check-in status, today's sessions, and registered-device notice.
- **Organiser dashboard:** live session identity and countdown, present/enrolled totals, rotating-token status, live roster with signal indicator, manual attendance controls, session close, and CSV/history entry.
- **History:** recent sessions and attendance totals, with export action for organisers.

## Current implementation

The Flutter client uses a Node.js service in [`backend/server.mjs`](backend/server.mjs) and a SQLite database. The service creates `backend/proxyproof.sqlite`, seeds the 2 faculty and 50 student accounts from `lib/demo_data.dart`, and provides sign-in, one-phone-per-student binding, five-minute sessions, five-second rotating BLE codes, server-side token freshness/RSSI/device checks, a live roster, manual attendance changes, session history, and CSV output. Faculty phones advertise; student phones scan and submit the observed code automatically. Node.js 22.5 or newer is required for its built-in SQLite module.

The current database and API run on the development computer. This is a complete local test setup, but it is not a hosted production deployment. Supabase/Postgres remains the planned hosted database; this folder does not contain a Supabase project or credentials. The local service intentionally uses demo accounts and a shared demo password, so do not use it for real student records. RSSI is measured by the student handset and sent to the service; it is a useful proximity filter, not cryptographic proof against a modified client or a sophisticated live relay.

### VPS test endpoint

A separate user-scoped test deployment is running at `https://api.homelabforme.online`. Its backend, SQLite database, Node.js runtime, Cloudflare tunnel config/credential, logs, and management scripts are in `/home/vishu/apps/proxyproof-vps-deploy` on the VPS. The full install/deployment inventory is in that folder's `DEPLOYMENT-INVENTORY.md`. To build an APK that connects to it, run:

```sh
flutter build apk --release --dart-define=PROXYPROOF_API=https://api.homelabforme.online
```

This endpoint still uses the shared demo password and demo accounts. Keep real attendance data off this test deployment.

The student screen polls the authenticated `GET /sessions/active` endpoint and displays live class names, rooms, faculty, and time remaining. BLE scanning still handles automatic attendance check-in when the student is nearby. If BLE check-in fails, the student can choose **Force present (fallback)** for an active class. This records `student_fallback` in the faculty roster and does not verify proximity; deploy the updated `backend/server.mjs` to the VPS before building/installing a client that uses this option.

Device binding is temporarily disabled on the VPS (`DEVICE_BINDING_ENABLED=false`) so demo accounts can sign in on either phone. Re-enable it by setting that flag to `true` in the VPS `start.sh` and restarting the service when device approval is ready to use.

## Demo accounts

The in-memory seed data contains **2 faculty accounts and 50 student accounts**. All demo emails use the `@proxyproof.demo` domain. Sign-in checks that the email exists under the selected role; because authentication is not connected yet, any non-empty password works. The quick-fill buttons use `demo` as the sample password.

| Name | Role | Demo email |
| --- | --- | --- |
| Alex Morgan | Faculty | alex.morgan@proxyproof.demo |
| Priya Shah | Faculty | priya.shah@proxyproof.demo |
| Aarav Mehta | Student | aarav.mehta@proxyproof.demo |
| Isha Kapoor | Student | isha.kapoor@proxyproof.demo |
| Kabir Shah | Student | kabir.shah@proxyproof.demo |
| Mira Rao | Student | mira.rao@proxyproof.demo |
| Reyansh Das | Student | reyansh.das@proxyproof.demo |
| Ananya Iyer | Student | ananya.iyer@proxyproof.demo |
| Dev Malhotra | Student | dev.malhotra@proxyproof.demo |
| Diya Nair | Student | diya.nair@proxyproof.demo |
| Arjun Menon | Student | arjun.menon@proxyproof.demo |
| Zoya Khan | Student | zoya.khan@proxyproof.demo |
| Vihaan Joshi | Student | vihaan.joshi@proxyproof.demo |
| Sana Bhat | Student | sana.bhat@proxyproof.demo |
| Aditya Verma | Student | aditya.verma@proxyproof.demo |
| Aditi Kulkarni | Student | aditi.kulkarni@proxyproof.demo |
| Ayaan Desai | Student | ayaan.desai@proxyproof.demo |
| Avni Sethi | Student | avni.sethi@proxyproof.demo |
| Dhruv Patel | Student | dhruv.patel@proxyproof.demo |
| Ira Chawla | Student | ira.chawla@proxyproof.demo |
| Kian Thomas | Student | kian.thomas@proxyproof.demo |
| Kavya Reddy | Student | kavya.reddy@proxyproof.demo |
| Neel Joshi | Student | neel.joshi@proxyproof.demo |
| Myra Sen | Student | myra.sen@proxyproof.demo |
| Rohan Gupta | Student | rohan.gupta@proxyproof.demo |
| Tara Menon | Student | tara.menon@proxyproof.demo |
| Samar Gill | Student | samar.gill@proxyproof.demo |
| Nisha Pillai | Student | nisha.pillai@proxyproof.demo |
| Parth Bansal | Student | parth.bansal@proxyproof.demo |
| Rhea Dsouza | Student | rhea.dsouza@proxyproof.demo |
| Yash Oberoi | Student | yash.oberoi@proxyproof.demo |
| Kiara Fernandes | Student | kiara.fernandes@proxyproof.demo |
| Om Prakash | Student | om.prakash@proxyproof.demo |
| Shreya Mukherjee | Student | shreya.mukherjee@proxyproof.demo |
| Ishaan Bhattacharya | Student | ishaan.bhattacharya@proxyproof.demo |
| Meera Krishnan | Student | meera.krishnan@proxyproof.demo |
| Atharv Sinha | Student | atharv.sinha@proxyproof.demo |
| Pooja Nair | Student | pooja.nair@proxyproof.demo |
| Rahul Nambiar | Student | rahul.nambiar@proxyproof.demo |
| Saanvi Bose | Student | saanvi.bose@proxyproof.demo |
| Manav Choudhary | Student | manav.choudhary@proxyproof.demo |
| Anika Hegde | Student | anika.hegde@proxyproof.demo |
| Advik Kaur | Student | advik.kaur@proxyproof.demo |
| Hridhaan Roy | Student | hridhaan.roy@proxyproof.demo |
| Tanvi Deshpande | Student | tanvi.deshpande@proxyproof.demo |
| Kushal Jain | Student | kushal.jain@proxyproof.demo |
| Ritika Ghosh | Student | ritika.ghosh@proxyproof.demo |
| Aarohi Banerjee | Student | aarohi.banerjee@proxyproof.demo |
| Nikhil Rao | Student | nikhil.rao@proxyproof.demo |
| Vanya Iyer | Student | vanya.iyer@proxyproof.demo |
| Eshan Mallick | Student | eshan.mallick@proxyproof.demo |
| Kavish Arora | Student | kavish.arora@proxyproof.demo |

## Run the app on a USB-connected Android phone

1. In one terminal, start the SQL service:

   ```sh
   node backend/server.mjs
   ```

2. In a second terminal, forward the phone's localhost port to the computer:

   ```sh
   adb reverse tcp:8787 tcp:8787
   ```

3. Start the Flutter app:

```sh
flutter pub get
flutter run -d <device-id>
```

The service prints `52 seeded accounts; demo password: demo` on first start. Demo emails and roles are listed above. Student and faculty phones need Bluetooth enabled and the app's Bluetooth permissions granted. For two-phone BLE testing, the faculty and student must each run the app. A second phone must reach the service by Wi-Fi: start it with `HOST=0.0.0.0` and launch its app with `--dart-define=PROXYPROOF_API=http://<computer-lan-ip>:8787`.

To build a debug APK for installation after testing:

```sh
flutter build apk --debug
```

The APK is written to `build/app/outputs/flutter-apk/app-debug.apk`. Do not distribute the local demo service or demo credentials as a production deployment. A hosted Supabase/Postgres project, production authentication, security review, and two-device/range testing are still required before real-world use.
