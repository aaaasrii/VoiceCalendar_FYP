# 🎙️ Voca Assist (VoiceCalendar_FYP)

An AI-powered voice assistant application built with Flutter. Voca Assist seamlessly converts natural speech into structured calendar events using Google Gemini AI and integrates directly with native device calendars.

## ✨ Core Features
* **Speech-to-Text Integration:** Captures voice commands accurately using native on-device speech recognition.
* **AI NLP Parsing:** Utilizes Google Gemini (`firebase_ai`) to intelligently parse conversational time, dates, and event titles from raw text.
* **Native Calendar Sync:** Automatically bridges the parsed data into the iOS Apple Calendar or Google Calendar via `add_2_calendar`.
* **Cross-Platform:** Built with Flutter, supporting seamless deployment on modern mobile operating systems.

## 🛠 Tech Stack & Dependencies
* **Framework:** Flutter SDK (`^3.11.0`)
* **AI Engine:** Google Generative AI / Firebase AI (`^3.11.0`)
* **Backend Service:** Firebase Core, Auth, Cloud Firestore (`^6.4.1`)
* **Key Plugins:** `speech_to_text`, `add_2_calendar`, `record`

## ⚙️ Prerequisites & System Requirements
To build and run this project, ensure your development environment meets the following requirements:
* **Flutter SDK:** Installed and added to PATH.
* **iOS Target:** Minimum **iOS 15.0** (Strictly enforced due to Firebase native SDK requirements).
* **macOS:** Required for Xcode compilation and iOS deployment.

## 🚀 Installation & Setup

1. **Clone the repository:**
```bash
   git clone <repository_url>
   cd VoiceCalendar_FYP
```

2. **Fetch Flutter packages:**
```bash
   flutter clean
   flutter pub get
```

3. **iOS Specific Setup (CocoaPods):**
Due to Swift Package Manager (SPM) dependency constraints, ensure you run the pod installation:
```bash
   git clone <repository_url>
   cd VoiceCalendar_FYP
```

4. **Run the Application:**
You must pass the Gemini API Key during runtime using Dart defines:
```bash
    flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```