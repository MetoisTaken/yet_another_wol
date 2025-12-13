# Yet Another Wake on LAN (YAWoL)

<div align="center">

**Cross-platform Wake-on-LAN application**

[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20macOS%20|%20Windows-blue.svg)](https://github.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-GPL--3.0-red.svg)](LICENSE)

[English](#english) | [Türkçe](#turkish)

</div>

---

## <a name="english"></a>🇬🇧 English

### 📱 Overview

Yet Another Wake on LAN (YAWoL) is a modern, cross-platform application that allows you to remotely wake devices on your network. Built with Flutter, it runs on Android, iOS, macOS, and Windows.

**Tested Platforms**: The application has been tested on macOS, Android, iOS, and Windows.

### ✨ Features

#### 🔌 Wake-on-LAN Functionality
- Wake saved devices with a single tap
- Manual device addition (Name, IP address, MAC address)
- Device status monitoring (ping check)
- Edit and delete devices

#### 🔍 Network Scanning
- Discover devices through automatic network scanning
- Auto-detect device information (IP, MAC, hostname)
- Quick device addition from scan results

#### 📲 Widget Support
- **Android**: Quick access via home screen widget
- **iOS**: Home screen widget (requires App Group configuration)
- Wake devices directly from widget

#### 🖥️ Desktop Features
- **macOS & Windows**: System tray support
- **macOS**: Background mode (minimize to tray instead of close)
- **macOS**: Background notifications
- Quick actions for device management

#### 🎨 User Interface
- Material Design 3 theme
- Dynamic color support (Android 12+)
- macOS system accent color integration
- Light/dark theme support
- Modern and user-friendly interface

#### ⚡ Additional Features
- Undo support for delete operations
- Direct delete from device edit screen
- Platform-specific optimizations
- Background task management

### 📥 Installation

#### Android
1. Download the latest APK from [Releases](../../releases)
2. Install the APK on your device
3. Grant "Install from unknown sources" permission if needed

#### iOS
1. Download the IPA file from [Releases](../../releases)
2. Install using [AltStore](https://altstore.io/) or similar sideloading tool

> **Note**: iOS builds require sideloading.

#### macOS
1. Download the DMG file from [Releases](../../releases)
2. Open the DMG and drag the app to Applications folder
3. First launch: **Right-click → Open** to bypass Gatekeeper

#### Windows
1. Download the ZIP file from [Releases](../../releases)
2. Extract to your desired location
3. Launch the executable (`.exe`)

> **SmartScreen Warning**: If Windows SmartScreen appears, use "More info" → "Run anyway".

### 🚀 Usage

#### Adding Devices
1. **Manual Addition**:
   - Click the **+** button on the main screen
   - Enter device name, IP address, and MAC address
   - Press Save

2. **Via Network Scan**:
   - Click the **Scan** button on the main screen
   - View discovered devices
   - Tap the device you want to add

#### Waking Devices
- Tap the device card on the main screen
- Touch the device from widget (Android/iOS)
- Select from system tray (macOS/Windows)

#### Device Management
- **Edit**: Long press on device card or tap to edit
- **Delete**: Swipe left to delete (can be undone)
- **Status Check**: Device card automatically pings devices

### 🛠️ Development

#### Requirements
- Flutter SDK 3.10.3 or higher
- Dart SDK 3.10.3 or higher
- Platform-specific tools:
  - **Android**: Android SDK, Java 17
  - **iOS**: Xcode 15+, CocoaPods
  - **macOS**: Xcode 15+, CocoaPods
  - **Windows**: Visual Studio 2022 (C++ desktop development)

#### Building from Source

1. **Clone the repository**:
   ```bash
   git clone https://github.com/USERNAME/yet_another_wol.git
   cd yet_another_wol
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run code generation**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Platform-specific build**:

   **Android**:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

   **iOS**:
   ```bash
   flutter build ios --release --no-codesign
   ```

   **macOS**:
   ```bash
   flutter build macos --release
   ```

   **Windows**:
   ```bash
   flutter build windows --release
   ```

5. **Run in development mode**:
   ```bash
   flutter run
   ```

### 🔧 CI/CD

The project has automated build and release processes using GitHub Actions:

- **CI Pipeline**: Code checking and building on every push and PR
- **Release Pipeline**: Automatic release creation with version tags
- **Supported Platforms**: Android, iOS, macOS, Windows

See [.github/workflows](.github/workflows) folder for details.

### 📝 Project Structure

```
lib/
├── main.dart                    # Application entry point
└── src/
    ├── app.dart                 # Main app widget
    ├── core/                    # Core services
    │   └── services/            # Platform services
    │       ├── notification_service.dart
    │       ├── tray_service.dart
    │       ├── window_service.dart
    │       └── ...
    └── features/                # Feature modules
        ├── devices/             # Device management
        │   ├── data/            # Data layer (Repository)
        │   ├── domain/          # Domain models
        │   └── presentation/    # UI and controllers
        ├── scanner/             # Network scanning
        └── widget/              # Widget services
```

### 🧰 Technologies Used

- **Framework**: Flutter & Dart
- **State Management**: Riverpod 2.x
- **Routing**: GoRouter
- **Local Storage**: Hive
- **UI Theme**: FlexColorScheme + Material 3
- **Networking**: 
  - `wake_on_lan`: WoL packet sending
  - `network_tools`: Network scanning
  - `dart_ping`: Device status check
- **Platform Integration**:
  - `home_widget`: Widget support
  - `tray_manager`: System tray
  - `window_manager`: Window management
  - `flutter_local_notifications`: Notifications

### 🐛 Known Issues

- **iOS**: Network scanning requires appropriate iOS permissions
- **macOS**: May show Gatekeeper warning on first run

### 🤝 Contributing

Contributions are welcome! Please:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### 📄 License

This project is licensed under the GPL-3.0 License. See [LICENSE](LICENSE) file for details.

### 🙏 Acknowledgments

This project uses amazing packages developed by the open-source community.

---

## <a name="turkish"></a>🇹🇷 Türkçe

### 📱 Genel Bakış

Yet Another Wake on LAN (YAWoL), ağınızdaki cihazları uzaktan uyandırmanıza olanak tanıyan modern, çok platformlu bir uygulamadır. Flutter ile geliştirilmiş olup Android, iOS, macOS ve Windows üzerinde çalışır.

**Test Edilen Platformlar**: Uygulama macOS, Android, iOS ve Windows üzerinde test edilmiştir.

### ✨ Özellikler

#### 🔌 Wake-on-LAN İşlevselliği
- Kaydedilmiş cihazları tek dokunuşla uyandırma
- Manuel cihaz ekleme (Ad, IP adresi, MAC adresi)
- Cihaz durumu izleme (ping kontrolü)
- Cihaz düzenleme ve silme

#### 🔍 Ağ Tarama
- Otomatik ağ taraması ile cihazları keşfetme
- Cihaz bilgilerini otomatik algılama (IP, MAC, hostname)
- Tarama sonuçlarından hızlı cihaz ekleme

#### 📲 Widget Desteği
- **Android**: Ana ekran widget'ı ile hızlı erişim
- **iOS**: Ana ekran widget'ı (App Group yapılandırması gerektirir)
- Widget'tan doğrudan cihaz uyandırma

#### 🖥️ Masaüstü Özellikleri
- **macOS & Windows**: Sistem tepsisi desteği
- **macOS**: Arka planda çalışma modu (kapatma yerine tepsiye minimize)
- **macOS**: Arka plan bildirimleri
- Hızlı eylemler ile cihaz yönetimi

#### 🎨 Kullanıcı Arayüzü
- Material Design 3 teması
- Dinamik renk desteği (Android 12+)
- macOS sistem vurgu rengi entegrasyonu
- Açık/koyu tema desteği
- Modern ve kullanıcı dostu arayüz

#### ⚡ Ek Özellikler
- Silme işlemlerinde geri alma desteği
- Cihaz düzenleme ekranında direkt silme
- Platform bazlı optimizasyonlar
- Arka plan görev yönetimi

### 📥 Kurulum

#### Android
1. [Releases](../../releases) sayfasından en son APK dosyasını indirin
2. APK'yı cihazınıza yükleyin
3. Gerekirse "Bilinmeyen kaynaklardan yükleme" iznini verin

#### iOS
1. [Releases](../../releases) sayfasından IPA dosyasını indirin
2. [AltStore](https://altstore.io/) veya benzeri bir sideloading aracı kullanarak yükleyin

> **Not**: iOS yapıları sideloading gerektirir.

#### macOS
1. [Releases](../../releases) sayfasından DMG dosyasını indirin
2. DMG'yi açın ve uygulamayı Applications klasörüne sürükleyin
3. İlk açılışta: **Sağ tıklama → Aç** yaparak Gatekeeper'ı atlayın

#### Windows
1. [Releases](../../releases) sayfasından ZIP dosyasını indirin
2. İstediğiniz bir klasöre çıkartın
3. Çalıştırılabilir dosyayı (`.exe`) başlatın

> **SmartScreen Uyarısı**: Windows SmartScreen uyarısı görürseniz, "Daha fazla bilgi" → "Yine de çalıştır" seçeneğini kullanın.

### 🚀 Kullanım

#### Cihaz Ekleme
1. **Manuel Ekleme**:
   - Ana ekranda **+** butonuna tıklayın
   - Cihaz adı, IP adresi ve MAC adresini girin
   - Kaydet'e basın

2. **Ağ Taraması ile**:
   - Ana ekranda **Tara** butonuna tıklayın
   - Bulunan cihazları görüntüleyin
   - Eklemek istediğiniz cihaza tıklayın

#### Cihaz Uyandırma
- Ana ekrandaki cihaz kartına tıklayın
- Widget'tan (Android/iOS) cihaza dokunun
- Sistem tepsisinden (macOS/Windows) seçin

#### Cihaz Yönetimi
- **Düzenleme**: Cihaz kartına uzun basın veya düzenlemek için tıklayın
- **Silme**: Sola kaydırarak silin (geri alabilirsiniz)
- **Durum Kontrolü**: Cihaz kartı otomatik olarak cihazlara ping atar

### 🛠️ Geliştirme

#### Gereksinimler
- Flutter SDK 3.10.3 veya üzeri
- Dart SDK 3.10.3 veya üzeri
- Platform-spesifik araçlar:
  - **Android**: Android SDK, Java 17
  - **iOS**: Xcode 15+, CocoaPods
  - **macOS**: Xcode 15+, CocoaPods
  - **Windows**: Visual Studio 2022 (C++ desktop development)

#### Kaynak Koddan Derleme

1. **Depoyu klonlayın**:
   ```bash
   git clone https://github.com/USERNAME/yet_another_wol.git
   cd yet_another_wol
   ```

2. **Bağımlılıkları yükleyin**:
   ```bash
   flutter pub get
   ```

3. **Kod üretimi yapın**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Platform-spesifik derleme**:

   **Android**:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

   **iOS**:
   ```bash
   flutter build ios --release --no-codesign
   ```

   **macOS**:
   ```bash
   flutter build macos --release
   ```

   **Windows**:
   ```bash
   flutter build windows --release
   ```

5. **Geliştirme modunda çalıştırma**:
   ```bash
   flutter run
   ```

### 🔧 CI/CD

Proje, GitHub Actions kullanarak otomatik derleme ve release süreçlerine sahiptir:

- **CI Pipeline**: Her push ve PR'da kod kontrolü ve derleme
- **Release Pipeline**: Version tag'leri ile otomatik release oluşturma
- **Desteklenen Platformlar**: Android, iOS, macOS, Windows

Detaylar için [.github/workflows](.github/workflows) klasörüne bakın.

### 📝 Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
└── src/
    ├── app.dart                 # Ana uygulama widget'ı
    ├── core/                    # Çekirdek servisler
    │   └── services/            # Platform servisleri
    │       ├── notification_service.dart
    │       ├── tray_service.dart
    │       ├── window_service.dart
    │       └── ...
    └── features/                # Özellik modülleri
        ├── devices/             # Cihaz yönetimi
        │   ├── data/            # Veri katmanı (Repository)
        │   ├── domain/          # Domain modelleri
        │   └── presentation/    # UI ve kontrolcüler
        ├── scanner/             # Ağ tarama
        └── widget/              # Widget servisleri
```

### 🧰 Kullanılan Teknolojiler

- **Framework**: Flutter & Dart
- **State Management**: Riverpod 2.x
- **Routing**: GoRouter
- **Local Storage**: Hive
- **UI Theme**: FlexColorScheme + Material 3
- **Networking**: 
  - `wake_on_lan`: WoL paket gönderimi
  - `network_tools`: Ağ tarama
  - `dart_ping`: Cihaz durumu kontrolü
- **Platform Integration**:
  - `home_widget`: Widget desteği
  - `tray_manager`: Sistem tepsisi
  - `window_manager`: Pencere yönetimi
  - `flutter_local_notifications`: Bildirimler

### 🐛 Bilinen Sorunlar

- **iOS**: Ağ tarama için uygun iOS izinleri gerektirir
- **macOS**: İlk çalıştırmada Gatekeeper uyarısı gösterebilir

### 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen:

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

### 📄 Lisans

Bu proje GPL-3.0 lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

### 🙏 Teşekkürler

Bu proje açık kaynak topluluğu tarafından geliştirilen harika paketleri kullanmaktadır.
