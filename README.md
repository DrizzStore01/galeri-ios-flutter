# 🖼️ Galeri — iOS-Style Android Gallery App

<p align="center">
  <strong>Aplikasi galeri foto Android bergaya iOS yang elegan dan berfitur lengkap</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.22+-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Android-8.0+-green?logo=android" />
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?logo=dart" />
  <img src="https://img.shields.io/badge/CI%2FCD-Codemagic-orange?logo=codemagic" />
</p>

---

## ✨ Fitur

| Kategori | Fitur |
|---|---|
| 📸 **Galeri** | Grid foto & video, tampilan per album, grouping per tanggal |
| 🔍 **Viewer** | Full-screen, pinch-to-zoom, swipe antar foto, video player |
| ✂️ **Editor** | Crop, brightness, contrast, saturation, filter, rotate, flip |
| ⭐ **Favorit** | Tandai foto favorit, tampilan khusus favorit |
| 🎞️ **Slideshow** | Auto-advance dengan crossfade animation |
| 🗑️ **Trash** | Hapus sementara, auto-delete setelah 30 hari |
| ☁️ **Backup** | UI manajemen backup (integrasi cloud coming soon) |
| 🔗 **Share** | Bagikan foto/video ke aplikasi lain |

## 🎨 Design System

- **Tema**: Light + Dark mode (auto)
- **Warna**: iOS color palette (iOS Blue #007AFF, #0A84FF)
- **Font**: SF Pro Display (judul), SF Pro Text (body)
- **UX**: iOS-style animations, bottom sheets, large title navbar

## 🏗️ Arsitektur

```
lib/
├── core/
│   ├── constants/      # Konstanta app (warna, ukuran, dll)
│   ├── theme/          # AppTheme light & dark
│   ├── extensions/     # BuildContext extensions
│   └── utils/          # Helper (permission, date formatter)
├── data/
│   ├── models/         # MediaItem, AlbumModel, EditConfig
│   ├── repositories/   # MediaRepository (photo_manager + Hive)
│   └── providers/      # Riverpod providers
├── presentation/
│   ├── screens/        # Semua halaman app
│   │   ├── home/       # HomeScreen, SlideshowScreen
│   │   ├── album/      # AlbumScreen, AlbumDetailScreen
│   │   ├── viewer/     # PhotoViewerScreen
│   │   ├── editor/     # PhotoEditorScreen
│   │   ├── favorites/  # FavoritesScreen
│   │   ├── trash/      # TrashScreen
│   │   └── backup/     # BackupScreen
│   └── widgets/        # Reusable widgets
│       ├── common/     # IOSAppBar, IOSBottomSheet, PermissionGate
│       └── gallery/    # MediaThumbnail, DateSectionHeader
└── l10n/               # Lokalisasi (id, en)
```

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter 3.22+
- Android Studio / VS Code
- Android device / emulator (API 26+)

### Setup

```bash
# 1. Clone & masuk ke folder
git clone <repo-url>
cd ios_gallery_app

# 2. Install dependencies
flutter pub get

# 3. Generate code (Hive adapters, Riverpod, localization)
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# 4. Jalankan di device
flutter run
```

### Font Setup (Penting!)

App ini menggunakan **SF Pro** font (font khas iOS). Karena SF Pro adalah font proprietary Apple, ada dua opsi:

**Opsi A — Gunakan SF Pro (Untuk development & testing)**
1. Download dari [developer.apple.com/fonts](https://developer.apple.com/fonts/)
2. Ekstrak dan copy ke `assets/fonts/`:
   - `SFProDisplay-Regular.ttf`
   - `SFProDisplay-Medium.ttf`
   - `SFProDisplay-Semibold.ttf`
   - `SFProDisplay-Bold.ttf`
   - `SFProText-Regular.ttf`
   - `SFProText-Medium.ttf`
   - `SFProText-Semibold.ttf`

**Opsi B — Gunakan Inter (Open source, mirip SF Pro)**
1. Download [Inter font](https://fonts.google.com/specimen/Inter) dari Google Fonts
2. Update `pubspec.yaml` ganti nama font family ke `Inter`

## 🔧 CI/CD dengan Codemagic

Project ini sudah include `codemagic.yaml` dengan **3 workflow**:

| Workflow | Trigger | Output |
|---|---|---|
| `android-pr-check` | Pull Request | Analyze + Test |
| `android-debug-build` | Push ke `develop` | Debug APK |
| `android-release-build` | Push ke `main`/tag `v*` | Release AAB + APK |

### Setup Codemagic

1. **Connect Repository**: Login ke [codemagic.io](https://codemagic.io) → Add App → pilih repo
2. **Setup Keystore**:
   - Settings → Code signing → Upload keystore `.jks`
   - Beri nama `ios_gallery_keystore`
3. **Setup Google Play Credentials** (untuk publish):
   - Buat Service Account di Google Play Console
   - Download JSON key
   - Di Codemagic: Settings → Integrations → Google Play → Upload JSON
   - Tambahkan ke environment group `google_play_credentials`
4. **Update email** di `codemagic.yaml` sesuai email lo

## 📦 Dependencies Utama

| Package | Versi | Kegunaan |
|---|---|---|
| `photo_manager` | ^3.3.0 | Akses foto & video dari storage |
| `photo_view` | ^0.15.0 | Pinch-to-zoom viewer |
| `flutter_riverpod` | ^2.5.1 | State management |
| `go_router` | ^13.2.0 | Navigation |
| `hive_flutter` | ^1.1.0 | Local storage (favorites, trash) |
| `image_editor_plus` | ^3.0.0 | Edit foto |
| `share_plus` | ^9.0.0 | Share ke aplikasi lain |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `animations` | ^2.0.11 | Material motion transitions |
| `shimmer` | ^3.0.0 | Loading skeleton |

## 🔒 Permissions

| Permission | Untuk |
|---|---|
| `READ_MEDIA_IMAGES` (API 33+) | Akses foto |
| `READ_MEDIA_VIDEO` (API 33+) | Akses video |
| `READ_EXTERNAL_STORAGE` (< API 33) | Akses storage lama |
| `VIBRATE` | Haptic feedback |

## 📝 License

MIT License — bebas digunakan untuk project personal maupun komersial.
