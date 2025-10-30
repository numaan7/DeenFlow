# DeenFlow 🔥
**Vibe Check: Your Ibadah Streak is on Lock** 🔒

A modern Islamic habit tracker built with Flutter, designed to help Muslims maintain consistency in their daily spiritual practices through beautiful UI and gamified progress tracking.

## ✨ Features

- **Three Core Islamic Habits**: Fajr Salah, Quran Reading, and Dhikr
- **Streak Tracking**: Visual progress indicators and day counters  
- **Vibe Check Dashboard**: Overall consistency metrics and daily progress
- **Squads Leaderboard**: Community accountability and friendly competition
- **Dark Theme UI**: Midnight blue design with teal accent colors
- **Smooth Animations**: Satisfying completion feedback and interactions
- **Mock Native Features**: Wake-up notifications and home screen widgets

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.24.5+ 
- Git
- A web browser

### Run Locally

```bash
# Clone the repository
git clone https://github.com/numaan7/DeenFlow.git
cd DeenFlow

# Get Flutter dependencies
flutter pub get

# Run on web (recommended for development)
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

# Or run on Chrome/Edge for better debugging
flutter run -d chrome
```

The app will be available at `http://localhost:8080`

### Development in Codespaces

This project is optimized for GitHub Codespaces with dev containers:

1. Open in Codespaces
2. Flutter SDK is automatically installed
3. Run `flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0`
4. Access via the forwarded port in your browser

## 📱 Usage

1. **Complete Habits**: Tap the circular buttons to mark habits as completed
2. **View Progress**: Check your "Vibe Check" streak and consistency rate
3. **Settings**: Toggle mock notifications and preview home screen widget
4. **Squads**: View leaderboard and compete with your community
5. **Reset Progress**: Use settings to reset daily completion for testing

## 🎨 Design

- **Color Palette**: Deep gray/midnight blue background with vibrant teal accents
- **Typography**: Clean, bold fonts with ample spacing
- **Layout**: Card-based design with rounded corners and subtle shadows
- **Inspiration**: Modeled after the premium aesthetic of Momentum: Energising Habits

## 🛠 Architecture

- **Single File Implementation**: Complete app in `lib/main.dart` for simplicity
- **Custom State Management**: Built-in ChangeNotifier pattern without external dependencies
- **Mock Integrations**: UI demonstrations of native OS features
- **Responsive Design**: Works on web, mobile, and desktop platforms

## 🔧 Technical Details

- **Framework**: Flutter 3.24.5
- **Language**: Dart 3.5.4
- **State Management**: Custom ChangeNotifier implementation
- **Dependencies**: Flutter SDK only (no external packages)
- **Platforms**: Web, iOS, Android, macOS, Windows, Linux

## 📝 License

This project is open source and available under the MIT License.
