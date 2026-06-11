<div align="center">

  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:3C3B3F,100:2E8AF6&height=250&section=header&text=Flutter%20Chat%20App&fontSize=70&fontAlign=50&fontAlignY=35&animation=fadeIn&desc=Premium%20Real-time%20Messaging%20Experience&descAlign=50&descAlignY=60&descSize=20" alt="Flutter Chat App Header" width="100%" />

<div align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=22&pause=1000&color=F7F7F7&background=0D1117&center=true&vCenter=true&width=600&lines=Flutter+Powered+%F0%9F%9A%80;Real-time+Messaging+%F0%9F%92%AC;Secure+Authentication+%F0%9F%94%91;Beautiful+Glassmorphism+UI+%E2%9C%A8;Connect+with+Friends..." alt="Typing Animation" />
  </a>
</div>
  
  <br>

  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/Bloc-State_Management-blue?style=for-the-badge" alt="Bloc" />
    <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
  </p>

</div>

---

## 📖 About The Project

**Flutter Chat App** is a premium, real-time messaging application designed with a focus on aesthetics and performance. Built with Flutter and Firebase, it offers a seamless communication experience with a modern glassmorphism UI design.

This project demonstrates **Production-Grade Flutter Development**:
* **🔐 Secure Auth:** Robust Email/Password authentication flow with "Forgot Password" capability.
* **💬 Real-time Chat:** Instant messaging powered by Cloud Firestore.
* **📞 1-to-1 Calling:** Real-time voice and video calling powered by Agora RTC Engine with a glassmorphic floating control bar.
* **🔔 Smart Notifications:** Unread message indicators and friend request badges.
* **✨ Modern UI:** Slippery animations, glass cards, and a sleek dark mode.
* **🏗️ Clean Architecture:** Scalable codebase using Feature-First structure and BLoC for state management.
* **🧠 Single Responsibility:** Highly refactored code following SRP principles.

<br>

## 🛠️ Tech Stack & Tools

<div align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=flutter,dart,firebase,vscode,git,github&perline=7" />
  </a>
</div>

**Key Packages:**
* `flutter_bloc`: Explicit state management.
* `go_router`: Declarative routing.
* `cloud_firestore`: Real-time database.
* `firebase_auth`: User authentication.
* `agora_rtc_engine`: Ultra-low latency voice & video call streams.
* `permission_handler`: Granular runtime permissions for audio and video feeds.
* `animate_do`: Beautiful entrance animations.
* `another_flushbar`: Elegant in-app notifications.

<br>

## ⚡ Quick Start Guide

Follow these steps to get the app running on your local machine.

### 1. Clone & Install
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/flutter-chat-app.git

# Enter directory
cd flutter-chat-app

# Install dependencies
flutter pub get
```

### 2. Configure Firebase

1. Create a project in [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password).
3. Enable **Cloud Firestore** (Create Database).
4. Configure `flutterfire` or add `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).

### 3. Run the App

```bash
# Run on connected device/emulator
flutter run
```

## 📱 Features

| Feature | Description |
| --- | --- |
| **Authentication** | Login, Registration, and Password Recovery flows with validation. |
| **Real-time Chat** | Send and receive messages instantly. Auto-scroll to bottom. |
| **User Discovery** | "Explore" tab to search and find other users/mentors. |
| **Friend System** | Send, Accept, and Reject connection requests. |
| **Notifications** | Red dot indicators on avatars and bottom nav for unread messages. |
| **Profile** | customizable profile with avatar, bio, and expertise tags. |
| **Voice & Video Calling** | 1-to-1 low-latency audio/video communication with camera switching, mic/video toggles, active timers, and Picture-in-Picture feeds. |
| **Dark Mode** | Default sleek dark theme with neon accents. |

## 📂 Project Structure

```text
lib/
├── core/                  # Core utilities, services, and shared widgets
├── features/              # Feature-based modules
│   ├── auth/              # Login, Register, Forgot Password
│   ├── calling/           # Real-time Voice & Video calling (Agora + BLoC)
│   ├── chat/              # Chat Logic, UI, and Service
│   ├── home/              # Dashboard, Explore, Navigation
│   └── profile/           # User Profile & Settings
├── router/                # App Navigation Configuration
└── main.dart              # Entry point
```

<div align="center">

<h3>👤 Author</h3>

<p><b>Jack</b></p>
<!-- Replace with your actual info -->

<p>
<a href="#" target="_blank">
<img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="Connect on LinkedIn"/>
</a>
<a href="#" target="_blank">
<img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="Follow on GitHub"/>
</a>
</p>

<sub><i>Built with ❤️ using Flutter</i></sub>

</div>