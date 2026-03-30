# Lietuvos Herbai – Flutter App

## Reikalavimai

- Flutter SDK ≥ 3.3.0 → https://docs.flutter.dev/get-started/install
- Dart ≥ 3.3.0 (ateina kartu su Flutter)

## Įdiegimas

```bash
# 1. Atidaryk terminalą ir eik į projekto aplanką
cd ~/Downloads/herbai_app

# 2. Įdiek priklausomybes
flutter pub get

# 3. Testuok telefone (Expo stiliaus – tiesiogiai be build'o)
flutter run

# Arba konkrečiai platformai:
flutter run -d android
flutter run -d ios
```

## Build APK (Android, be Play Store)

```bash
flutter build apk --release
# Rezultatas: build/app/outputs/flutter-apk/app-release.apk
# Perkelk į telefoną ir įdiek
```

## Build iOS (TestFlight / Ad-hoc)

```bash
flutter build ios --release
# Reikia Xcode ir Apple Developer Account
```

## Projekto struktūra

```
herbai_app/
├── lib/
│   ├── main.dart              – Programos įėjimo taškas
│   ├── models/
│   │   └── herbas.dart        – Duomenų modelis
│   ├── screens/
│   │   ├── home_screen.dart   – Sąrašas + paieška + filtrai
│   │   └── detail_screen.dart – Konkretaus herbo detalės
│   └── widgets/
│       └── herbas_image.dart  – SVG/PNG/GIF/JPG atvaizdavimas
├── assets/
│   ├── data/
│   │   └── herbai.json        – 447 herbų metaduomenys
│   └── herbai/                – 447 paveikslėliai (PNG/SVG/GIF/JPG)
└── pubspec.yaml
```

## Funkcionalumas

- **Sąrašas** – visi 447 herbai su miniatiūra, pavadinimu, apskritimi
- **Paieška** – realaus laiko paieška pagal pavadinimą ar apskritį
- **Filtrai** – pagal tipą: Miestas / Rajonas / Savivaldybė / Seniūnija
- **Detailės** – paspaudus – herbas dideliu formatu + visa info
- **Offline** – visi ресурсai lokaliai, internetas nereikalingas

## Ateities plėtra (žaidimų rezultatai)

Projektas jau turi `shared_preferences` paketą. Žaidimo rezultatams:

```dart
import 'package:shared_preferences/shared_preferences.dart';

// Išsaugoti
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('highScore', 42);

// Nuskaityti
final score = prefs.getInt('highScore') ?? 0;
```

Sudėtingesniems duomenims (lentelės, istorija) – pridėk `sqflite` paketą.
