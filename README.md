# ProxyProof

Flutter app for classroom attendance using rotating Bluetooth Low Energy (BLE) session tokens.

## Build plan and status

1. **Role-based app and screens — implemented:** Faculty and Student login, live class list, student attendance history, faculty session dashboard, roster, manual attendance controls, and CSV export.
2. **Authentication and SQLite service — implemented for demo use:** Node.js API with SQLite persistence and seeded demo accounts. All demo accounts use the password `demo`.
3. **BLE attendance — implemented, device testing in progress:** Faculty broadcasts a random token that rotates every five seconds. Students scan and submit it; the server checks that it is fresh and the reported RSSI is at least -78 dBm. Faculty token rotations are serialized to avoid overlapping requests.
4. **Fallback check-in — implemented locally; VPS deployment pending:** Students can use **Force present (fallback)** for an active class. It records `student_fallback`, which the faculty roster identifies separately. This bypasses proximity verification and should be used only when BLE check-in fails.
5. **Phone validation and release — pending:** Verify BLE behavior on both Android phones, permissions, range, and fallback against the VPS API before making a release APK.

## Screen layout

- **Login:** Student/Faculty role selector, email and password fields, password visibility, and demo account shortcuts.
- **Student home:** Live classes with room, faculty, and time remaining; automatic BLE scan/check-in status; confirmed attendance state; fallback check-in for each active class; attendance history and percentage; device notice.
- **Faculty dashboard:** Start/close a live session, rotating BLE broadcast status, present roster, manual add/remove, device-change requests, and attendance export/history.

## Current implementation

The Flutter client uses the Node.js API in [`backend/server.mjs`](backend/server.mjs) and SQLite. SQLite persists users, sessions, rotating-token hashes, attendance marks, and device-change requests. The service seeds 2 faculty and 50 students from [`lib/demo_data.dart`](lib/demo_data.dart). Node.js 22.5 or newer is required for its built-in SQLite module.

The student live-class list is fetched separately from Bluetooth check-in. Seeing a class only confirms the API can return the active session; an automatic present mark requires the BLE token to be received and accepted. If it fails, check the student screen's scan/error message and that the faculty screen reports **Broadcasting**. The fallback uses the authenticated student account and an active session, but does not verify physical presence.

RSSI comes from the student handset and is useful as a proximity filter, not proof against a modified app or a live relay. Device binding exists, but is disabled on the VPS (`DEVICE_BINDING_ENABLED=false`) for two-phone demo logins. Do not use the shared demo credentials or this setup for real student records.

### VPS test endpoint

The API is at `https://api.homelabforme.online`. Its user-scoped files and deployment inventory are under `/home/vishu/apps/proxyproof-vps-deploy` on the VPS. The endpoint currently serves sign-in, live sessions, and the existing attendance API. **The new `POST /check-in/force` route is not deployed yet**; it returned `404 Route not found` when checked on 2026-10-17. The local machine could not SSH to the VPS because key/password authentication was denied, so the new [`backend/server.mjs`](backend/server.mjs) still needs to be copied to the VPS and the existing backend restarted. No Cloudflare settings were changed.

After deploying the backend route, build an APK that uses the VPS API:

```sh
flutter build apk --release --dart-define=PROXYPROOF_API=https://api.homelabforme.online
```

The deployment uses demo accounts and the shared demo password. Keep real attendance data off this test endpoint.

## Demo accounts

The seed data contains **2 faculty accounts and 50 student accounts**. All demo emails use the `@proxyproof.demo` domain. The API authenticates the selected role and email with the shared demo password `demo`. The account list is shown below.

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

## Run locally on a USB-connected Android phone

1. In one terminal, start the API and SQLite service:

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

The service seeds 52 accounts with password `demo`. Student and faculty phones need Bluetooth enabled and the app's Bluetooth permissions granted. For a second phone on Wi-Fi, start the service with `HOST=0.0.0.0` and run the app with `--dart-define=PROXYPROOF_API=http://<computer-lan-ip>:8787`.

To build a debug APK for a local `adb reverse` test:

```sh
flutter build apk --debug
```

The APK is written to `build/app/outputs/flutter-apk/app-debug.apk`. The VPS-targeted debug build uses the same path; build it with `--dart-define=PROXYPROOF_API=https://api.homelabforme.online`. Do not distribute the local demo service or demo credentials as production software. Production hosting, stronger authentication, security review, and device/range testing remain future work.
