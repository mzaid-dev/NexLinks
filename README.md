<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0D0D0D,50:2563EB,100:22D3EE&height=250&section=header&text=NexLinks&fontSize=80&fontAlign=50&fontAlignY=35&animation=fadeIn&fontColor=FFFFFF&desc=Connect%20•%20Collaborate%20•%20Create&descAlign=50&descAlignY=60&descSize=22" alt="NexLinks Header" width="100%" />

<div align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=22&pause=1000&color=22D3EE&background=0D1117&center=true&vCenter=true&width=700&lines=Premium+Developer+Networking+Platform+%F0%9F%9A%80;Real-time+Messaging+%26+Collaboration+%F0%9F%92%AC;Find+Mentors+%26+Build+Connections+%F0%9F%A4%9D;Beautiful+3D+UI+with+Glassmorphism+%E2%9C%A8" alt="Typing Animation" />
  </a>
</div>
  
  <br>

  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/BLoC-State_Management-2563EB?style=for-the-badge" alt="Bloc" />
    <img src="https://img.shields.io/badge/Clean_Architecture-22D3EE?style=for-the-badge" alt="Architecture" />
  </p>

</div>
  
  <br>

<div align="center">

## 🚀 Download NexLinks

**Get the latest version for your platform:**

[![Android](https://img.shields.io/badge/Android-APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/mzaid-dev/NexLinks/releases/latest/download/NexLinks.apk)
[![iOS](https://img.shields.io/badge/iOS-IPA-000000?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/mzaid-dev/NexLinks/releases/latest/download/NexLinks.ipa)
[![macOS](https://img.shields.io/badge/macOS-DMG-000000?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/mzaid-dev/NexLinks/releases/latest/download/NexLinks.dmg)
[![Windows](https://img.shields.io/badge/Windows-MSIX-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/mzaid-dev/NexLinks/releases/latest/download/NexLinks.msix)
[![Linux](https://img.shields.io/badge/Linux-Bundle-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://github.com/mzaid-dev/NexLinks/releases/latest/download/NexLinks.tar.gz)

> *Links point to the latest professional builds.*

</div>

---

## 🌟 About NexLinks

**NexLinks** is a premium developer networking and real-time messaging platform designed to help professionals connect, collaborate, and grow together. Built with Flutter and Firebase, it combines stunning UI with robust functionality.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>🔐</b></td>
      <td><b>Secure Authentication</b> - Email/Password, Google Sign-In, and Forgot Password flows</td>
    </tr>
    <tr>
      <td align="center"><b>💬</b></td>
      <td><b>Real-time Messaging</b> - Instant chat with message reactions and read receipts</td>
    </tr>
    <tr>
      <td align="center"><b>🔍</b></td>
      <td><b>Developer Discovery</b> - Find mentors and collaborators with the 3D Explore Carousel</td>
    </tr>
    <tr>
      <td align="center"><b>🤝</b></td>
      <td><b>Smart Connections</b> - Send, accept, and manage friend requests</td>
    </tr>
    <tr>
      <td align="center"><b>🔔</b></td>
      <td><b>Live Notifications</b> - Unread badges, online status indicators, and presence tracking</td>
    </tr>
    <tr>
      <td align="center"><b>✨</b></td>
      <td><b>Premium UI</b> - Glassmorphism, 3D carousels, tactile feedback, and smooth animations</td>
    </tr>
  </table>
</div>

<br>

## 🛠️ Tech Stack

<div align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=flutter,dart,firebase,androidstudio,vscode,git,github&perline=7" />
  </a>
</div>

<br>

| Category | Technologies |
|----------|-------------|
| **Frontend** | Flutter 3.9+, Dart, BLoC Pattern, GoRouter |
| **Backend** | Firebase Auth, Cloud Firestore, Firebase Storage |
| **State Management** | flutter_bloc, Equatable, Cubit |
| **UI/UX** | animate_do, shimmer, chiclet, cached_network_image |
| **Auth** | Email/Password, Google Sign-In, Flutter Secure Storage |
| **Notifications** | flutter_local_notifications, firebase_messaging |

<br>

## 🏗️ Architecture

NexLinks follows **Clean Architecture** with a **Feature-First** approach for maximum scalability and maintainability.

```
lib/
├── core/                          # Shared utilities & widgets
│   ├── services/                  # Firebase, Auth, Error handling
│   ├── theme/                     # App theming & colors
│   ├── utils/                     # Validators, helpers
│   └── widgets/                   # Reusable UI components
│       └── common/                # AppAvatar, AppButton, TactileFeedback
│
├── features/                      # Feature modules (Clean Architecture)
│   ├── auth/                      # Authentication feature
│   │   ├── data/                  # DataSources, Repositories, Models
│   │   ├── domain/                # Entities, Repository interfaces
│   │   ├── logic/                 # BLoC, Events, States
│   │   └── presentation/          # Screens, Widgets
│   │
│   ├── chat/                      # Real-time messaging
│   │   ├── data/                  # ChatService, Message models
│   │   ├── logic/                 # ChatBloc
│   │   └── presentation/          # ChatScreen, MessageBubble
│   │
│   ├── home/                      # Dashboard & navigation
│   │   ├── logic/                 # HomeNavigationCubit
│   │   └── presentation/          # HomeView, ExploreView
│   │
│   └── profile/                   # User profiles
│       └── presentation/          # ProfileScreen, EditProfileScreen
│
├── router/                        # GoRouter configuration
│   ├── app_router.dart
│   └── route_names.dart
│
└── main.dart                      # Entry point
```

<br>

## ⚡ Quick Start

### Prerequisites

- Flutter SDK 3.9+
- Firebase Project with Auth & Firestore enabled
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/mzaid-dev/NexLinks.git

# Navigate to project
cd NexLinks

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup

1. Create a project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** → Email/Password & Google
3. Enable **Cloud Firestore** (Start in test mode)
4. Add Android app with package: `com.nexlinks.social`
5. Download `google-services.json` → Place in `android/app/`
6. Add your SHA-1 fingerprint for Google Sign-In:
   ```bash
   cd android && ./gradlew signingReport
   ```

<br>

## 📱 Features Showcase

| Feature | Description |
|---------|-------------|
| **🔐 Multi-Auth** | Email/Password with validation, Google OAuth (Mobile), Password recovery |
| **👥 User Networking** | Stunning UI for discovering new connections |
| **💬 Smart Chat** | Real-time messaging with reactions, read receipts, and typing indicators |
| **🔴 Activity Status** | Live online/offline presence updates and unread message badges |
| **🌍 Cross-Platform** | Native support for Android, iOS, macOS, Windows, and Linux |
| **👤 Rich Profiles** | Avatar filters, bio, expertise tags, and project metrics |
| **🎨 Premium UI** | Dark theme, glassmorphism, and responsive tactile buttons |
| **🧹 Error Handling** | Centralized error handler with platform-specific smart guards |

<br>

## 🚀 Roadmap (Upcoming Features)

- [ ] **Push Notifications** (FCM integration for background alerts)
- [ ] **File Sharing** (Images, Documents, Voice Notes)
- [ ] **Audio/Video Calls** (WebRTC integration)
- [ ] **Group Chats** (Create and manage groups)
- [ ] **End-to-End Encryption** (Enhanced privacy)

<br>

## 🔧 Configuration

### Environment Variables

The app uses `google-services.json` for Firebase configuration. No additional `.env` files are required.

### Customization

| File | Purpose |
|------|---------|
| `lib/core/theme/app_theme.dart` | Colors, typography, component themes |
| `lib/router/app_router.dart` | Navigation routes and guards |
| `lib/core/services/error_handler.dart` | Error message customization |

<br>

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<br>

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

<br>

---

<div align="center">

<h3>👨‍💻 Author</h3>

<p><b>Muhammad Zaid</b></p>

<p>
<a href="https://github.com/mzaid-dev" target="_blank">
<img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"/>
</a>
<a href="https://linkedin.com/in/mzaid-dev" target="_blank">
<img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"/>
</a>
</p>

<br>

<sub><i>Built with ❤️ using Flutter & Firebase</i></sub>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0D0D0D,50:2563EB,100:22D3EE&height=120&section=footer" width="100%" />


</div>