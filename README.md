# 📱 DailyMoodFinal

**DailyMoodFinal** is a modern iOS application that allows users to track and reflect on their mood daily through an engaging and minimal user interface. Built using Swift, Firebase, and Lottie animations, the app supports journal entries, mood analysis, calendar browsing, and personalized insights.

---

## ✨ Features

### 🔐 Authentication
- Firebase Email/Password Sign-Up and Login
- Forgot password flow with phone number verification
- Profile image selection and cropping using `TOCropViewController`

### 🏠 Home
- Central hub screen with tab navigation
- Quick access to mood selection, journal, and profile

### 🎭 Mood Tracker
- Select a daily mood using expressive emojis
- Display a tailored daily tip based on the selected mood
- Cooldown timer between mood updates

### 📓 Mood Journal
- Guided journal entry with reflective questions
- Horizontal swipe navigation by day (`UIPageViewController`)
- Calendar dialog showing which days have entries ✅
- Ability to jump to any recorded day

### 👤 Profile
- View mood history pie chart (last 24 hours)
- See mood distribution (only emojis in chart, mood names in legend)
- View active usage time
- Navigate to Journal History screen
- Logout with confirmation alert

### 📊 Charts & Statistics
- Built-in pie chart using `DGCharts`
- Displays mood breakdown over the last 24 hours

### 🌈 Design & Animations
- Splash screen with Lottie animation (`lottie_open_screen`)
- Dark mode and Light mode support
- Modern, minimal, grayscale UI

---

## 📁 Project Structure

```
DailyMoodAppFinal/
├── App/
│   ├── AppDelegate.swift
│   ├── LaunchScreen.storyboard
│   └── SceneDelegate.swift
├── Managers/
│   └── FirebaseAuthManager.swift
├── Models/
│   ├── UserModel.swift
│   └── JournalEntry.swift
├── Modules/
│   ├── Auth/
│   │   ├── Login/
│   │   │   └── LoginViewController.swift
│   │   ├── Register/
│   │   │   └── RegisterViewController.swift
│   │   └── ForgotPassword/
│   │       └── ForgotPasswordViewController.swift
│   ├── Home/
│   │   ├── Profile/
│   │   │   └── ProfileViewController.swift
│   │   ├── Mood/
│   │   │   └── CurrentMoodViewController.swift
│   │   ├── Journal/
│   │   │   ├── JournalDayViewController.swift
│   │   │   ├── MoodJournalEntryViewController.swift
│   │   │   └── MoodJournalPageViewController.swift
│   │   └── HomeViewController.swift
│   └── Splash/
│       └── SplashViewController.swift
├── Dialogs/
│   └── CalendarDialogViewController.swift
├── Resources/
│   ├── Lottie/
│   │   └── lottie_open_screen.json
│   ├── Assets.xcassets
│   ├── GoogleService-Info.plist
│   ├── Info.plist
│   └── Main.storyboard
├── Tests/
│   ├── DailyMoodAppFinalTests/
│   └── DailyMoodAppFinalUITests/
```
---

## 🔧 Dependencies

- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Storage](https://firebase.google.com/docs/storage)
- [DGCharts (iOS Charts)](https://github.com/danielgindi/Charts)
- [Lottie-iOS](https://github.com/airbnb/lottie-ios)
- [TOCropViewController](https://github.com/TimOliver/TOCropViewController)

---

## 🖼️ Screenshots

## 🔐 Login & Registration

<p float="left">
  <img src="https://github.com/user-attachments/assets/25e1c4b7-0f20-4644-abc8-16720a741f51" alt="Login Screen" width="20%" />
  <img src="https://github.com/user-attachments/assets/72707a1b-d26d-4c05-9a91-1744ea4496a2" alt="Register Screen" width="20%" />
  <img src="https://github.com/user-attachments/assets/f67eb8fa-deb5-4851-8652-bbf65cf33381" alt="Forgot Password Screen" width="20%" />
</p>

---

## 👤 Profile

<p float="left">
  <img src="https://github.com/user-attachments/assets/bf7cefe5-0be7-4c91-8f38-72e1416530b3" alt="Profile Overview" width="20%" />
</p>

---

## 😃 Mood Tracker

<p float="left">
  <img src="https://github.com/user-attachments/assets/1939fcd8-a325-447c-80e7-879cde28adcb" alt="Mood Selection" width="20%" />
  <img src="https://github.com/user-attachments/assets/51246ed7-8bf3-4af7-b56a-9aaa3ae698d8" alt="Tip Shown" width="20%" />
</p>

---

## 📓 Journal

<p float="left">
  <img src="https://github.com/user-attachments/assets/5365d907-3e39-45a1-ac2f-07ecf4d06cac" alt="Journal Entry" width="20%" />
  <img src="https://github.com/user-attachments/assets/363e43b4-abb1-4a0b-81ac-4e470cc9419d" alt="Journal Swipe" width="20%" />
</p>

---

## 📅 Calendar Dialog

<p float="left">
  <img src="https://github.com/user-attachments/assets/0e01030b-2b32-4327-9240-59e0a1186e17" alt="Calendar View" width="20%" />
</p>

---

## 🚀 Getting Started

1. Clone this repo:
   ```bash
   git clone https://github.com/yourusername/DailyMoodFinal.git
   

2. Open the project in Xcode:
   ```bash
    open DailyMoodAppFinal.xcodeproj
    

3. Install Pods (if applicable):
    ```bash
    pod install

4. Replace GoogleService-Info.plist with your own from Firebase Console.

5. Run the app on a simulator or device.

---

### 🙋‍♂️ Author
Developed by Roei Hakmon
Feel free to reach out for questions, feedback, or collaboration.

