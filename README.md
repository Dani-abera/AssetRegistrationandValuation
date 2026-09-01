<div align="center">

# 🏠 Asset Registration & Valuation

### Digital land & house registration and valuation platform

**A Flutter + Firebase application for registering land and house assets, managing valuations, and generating reports — with role-based access for administrators, valuators, and asset owners.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)

</div>

---

## Overview

**Asset Registration & Valuation** digitizes how land and house property is registered, valued, and documented. Owners submit assets with supporting documents, valuators review and assign valuations, and administrators oversee the process — all backed by Firebase for authentication, real-time data, and file storage.

The app generates PDF reports for registered and valued assets, and supports document and image uploads so each asset carries its full paper trail digitally.

---

## Key Features

- **🔐 Authentication** — email/password and **Google Sign-In** via Firebase Auth
- **👥 Role-based access** — tailored experiences for **Administrators**, **Valuators**, and **Asset Owners**
- **🏠 Asset registration** — register land and house properties with detailed records
- **📈 Valuation workflow** — valuators review submissions and record property valuations
- **📄 PDF reports** — generate and view valuation/registration reports in-app
- **🖼️ Document & image uploads** — attach supporting files via Firebase Storage and Cloudinary
- **✉️ Email notifications** — send updates to users through the mailer integration
- **☁️ Cloud-backed** — Firestore for real-time data, Firebase Storage for files

---

## Tech Stack

| Area | Technologies |
|------|--------------|
| **Framework** | Flutter, Dart |
| **State management** | Riverpod, Provider, get_it (DI) |
| **Backend / cloud** | Firebase Auth, Cloud Firestore, Firebase Storage, Google APIs |
| **Auth** | Firebase Auth + Google Sign-In |
| **Files & media** | file_picker, image_picker, Cloudinary, cached_network_image, photo_view |
| **PDF** | pdf, flutter_pdfview, Syncfusion PDF viewer |
| **Email** | mailer |
| **Utilities** | intl, url_launcher, shared_preferences, uuid, open_file |

---

## Getting Started

```bash
# 1. Clone the repo
git clone https://github.com/Dani-abera/AssetRegistrationandValuation.git
cd AssetRegistrationandValuation

# 2. Install dependencies
flutter pub get

# 3. Add your Firebase configuration
#    - Android: android/app/google-services.json
#    - iOS:     ios/Runner/GoogleService-Info.plist
#    (create a Firebase project and enable Auth, Firestore, and Storage)

# 4. Run
flutter run
```

> **Prerequisites:** Flutter SDK, a Firebase project with Authentication, Cloud Firestore, and Storage enabled, and (for Google Sign-In) the OAuth client configured in Firebase.

---

## Roles at a Glance

| Role | Can do |
|------|--------|
| **Asset Owner** | Register land/house assets, upload documents, view their valuations & reports |
| **Valuator** | Review submitted assets, assign valuations, generate reports |
| **Administrator** | Oversee users and assets, manage the registration & valuation process |

---

## Screenshots

> _Add a few screenshots here — the registration form, an asset detail view, and a generated PDF report show this off best._

---

<div align="center">

Built by **[Daniel Abera Bogale](https://github.com/Dani-abera)** · Flutter + Firebase

</div>
