# 🎭 Rezerwacja Miejsc – System Rezerwacji Biletów Teatralnych / Kinowych

Aplikacja Flutter do zarządzania rezerwacjami miejsc w teatrze lub kinie.  
Projekt obsługuje zarówno **użytkowników**, którzy mogą przeglądać i rezerwować spektakle, jak i **administratorów**, którzy zarządzają repertuarem, rezerwacjami i użytkownikami.

---

## 🧩 Funkcjonalności

### 👤 Dla użytkownika:
- 🔑 Rejestracja i logowanie (Supabase Auth)  
- 🎟️ Przeglądanie dostępnych spektakli  
- 💺 Rezerwacja miejsc na wybrany spektakl  
- 📋 Podgląd swoich rezerwacji  
- ❌ Anulowanie istniejących rezerwacji  
- 🔁 Resetowanie hasła za pomocą linku e-mail  
- 🚪 Bezpieczne wylogowanie z aplikacji  

### 🛠️ Dla administratora:
- 🎬 Dodawanie nowych spektakli (tytuł, opis, data, obraz, czas trwania)  
- ✏️ Edycja istniejących spektakli  
- 🗑️ Usuwanie spektakli (manualnie lub automatycznie po upływie daty wydarzenia)  
- ✅ Potwierdzanie rezerwacji użytkowników  
- 👁️ Podgląd wszystkich rezerwacji  

---

## 🧱 Technologia

| Warstwa | Technologia |
|----------|--------------|
| Frontend | **Flutter (Dart)** |
| Backend | **Supabase (PostgreSQL + Auth)** |
| UI Routing | **go_router** |
| Konfiguracja środowiska | **flutter_dotenv** |
| Hosting (web) | **Firebase Hosting / Supabase Edge / GitHub Pages** |

---

## 🗂️ Struktura katalogów

lib/
├── features/
│ ├── auth/ # Logowanie, rejestracja, reset hasła
│ │ └── screens/
│ ├── user/ # Funkcje użytkownika
│ │ └── screens/
│ │ ├── user_home_screen.dart
│ │ ├── spectacle_list_screen.dart
│ │ ├── reservation_screen.dart
│ │ └── user_reservations_screen.dart
│ ├── admin/ # Panel administratora
│ │ └── screens/
│ │ ├── admin_panel_screen.dart
│ │ ├── admin_spectacle_list_screen.dart
│ │ └── admin_reservation_list_screen.dart
│ ├── shows/
│ │ └── add_show_screen.dart
│ └── shared/ # Komponenty wspólne (np. widgety, style)
├── main.dart
├── router.dart
└── utils/


---

## ⚙️ Instalacja i konfiguracja

### 1️⃣ Klonowanie repozytorium
```bash
git clone https://github.com/twoj-login/rezerwacja-miejsc.git
cd rezerwacja-miejsc
2️⃣ Instalacja zależności
flutter pub get
3️⃣ Utworzenie pliku .env

W katalogu głównym projektu utwórz plik .env i dodaj swoje dane Supabase:
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
🧩 Wymagania systemowe

Flutter SDK 3.16 lub nowszy

Dart 3+

Konto w Supabase

Zainstalowany emulator Android / Chrome / iOS

🖼️ Zrzuty ekranu
Ekran	Opis
🏠 Panel użytkownika	Dostęp do rezerwacji i spektakli
🎬 Lista spektakli	Karty z plakatami, opisem i datą
💺 Rezerwacja	Wybór miejsc na sali
🧑‍💼 Panel administratora	Zarządzanie spektaklami i rezerwacjami

(dodaj tutaj swoje zrzuty ekranu po zbudowaniu aplikacji)

🔐 Autoryzacja i bezpieczeństwo

Autentykacja oparta o Supabase Auth (email + hasło)

Token sesji przechowywany w Supabase — automatyczne odświeżanie po restarcie aplikacji

Oddzielne panele dla użytkownika i administratora

🧠 Możliwości rozbudowy

📅 Widok kalendarza spektakli

🎫 Generowanie biletów PDF z kodem QR

💳 Integracja z systemem płatności (np. Stripe)

📲 Powiadomienia push o nadchodzącym spektaklu
