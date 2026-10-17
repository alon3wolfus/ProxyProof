# ProxyProof

ProxyProof records classroom attendance after a student's phone detects a nearby faculty Bluetooth Low Energy (BLE) broadcast. The session token rotates during class, and the server checks the token and reported signal strength before recording a check-in.

## Where the app stands

The Flutter app has faculty and student accounts, live sessions, automatic BLE check-in, attendance history, faculty roster controls, and CSV export. The Node.js service stores demo users, sessions, token data, and attendance in SQLite. This is a working demo deployment; use demo records only.

Students do not need to tap a check-in button. Once a faculty member starts a session, students can open the app and the phone scans for the session automatically. If scanning stalls, **Restart check-in** restarts Bluetooth discovery; it does not create an attendance mark. Attendance still requires the normal BLE token validation.

## Try it on Android

The app connects to the hosted API at `https://api.homelabforme.online` by default. Sign in on one phone as faculty and another as a student:

1. Sign in as faculty and start a session. Keep the app open and confirm the screen reports **Broadcasting**.
2. Sign in as a student, open the live class, and keep the app open while it scans. A successful check-in appears in the faculty roster.
3. If the student scan does not start or stalls, use **Restart check-in** on that class. Check the error/status shown in the app and confirm Bluetooth permissions are allowed.

Keep Bluetooth on and both apps in the foreground while validating. Android 12 and newer require Nearby Devices permissions. Android 11 and earlier may also require Location permission and the phone's Location setting for BLE scanning. Background scanning and advertising are not implemented. The current advertising format supports Android; faculty advertising on iOS needs a different BLE protocol.

### Demo sign-ins

All demo accounts use the password `demo`. There are two faculty accounts and 50 student accounts. The full list is available below if you need an account other than the two quick-start examples.

- Faculty: `alex.morgan@proxyproof.demo`
- Student: `aarav.mehta@proxyproof.demo`

<details>
<summary>Show all 52 demo accounts</summary>

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

</details>

## Get the Android APK

The current universal APK is [`ProxyProof.apk`](ProxyProof.apk). It connects to the hosted API and can be sideloaded on Android devices compatible with the app's minimum Android version. To rebuild it from the project root:

```sh
flutter pub get
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk ProxyProof.apk
```

The project currently signs release builds with Flutter's debug signing key for direct installation and testing. That is suitable for this demo APK; configure a private release key before publishing through an app store. Keep the demo credentials and endpoint limited to test data.

## Bluetooth and attendance notes

The faculty phone broadcasts a changing session token, and nearby student phones scan and submit it. The server accepts the check-in only when the session and token are current and the signal-strength check passes. RSSI is a proximity filter, not cryptographic proof of location; a modified client or live relay could defeat it. Device binding is disabled on the VPS to allow the two-phone demo flow. Do not use this setup for real student records.

If a live class appears for a student but no mark appears on the faculty roster, first confirm the faculty phone says **Broadcasting**, then check the student's scan status and permissions. Restart check-in to restart discovery, and verify both devices remain online.

## Optional: run the API on your development computer

The normal phone workflow uses the hosted API, so this local setup is only needed when developing the backend. Node.js 22.5 or newer is required for its built-in SQLite module.

```sh
node backend/server.mjs
```

For a phone on the same Wi-Fi network as the development computer, start the service so it accepts LAN connections and point Flutter at the computer's LAN address:

```sh
HOST=0.0.0.0 node backend/server.mjs
flutter run -d <device-id> --dart-define=PROXYPROOF_API=http://<computer-lan-ip>:8787
```

The server seeds the demo accounts on first use. Keep the local service and shared demo password on a trusted network.
