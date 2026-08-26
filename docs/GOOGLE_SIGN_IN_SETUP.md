# Google Sign-In setup

This document explains how to make Google Sign-In work for the app — including an
**unpublished** app in **testing mode**.

## Already configured in the repo

| Item | Value / location |
|------|------------------|
| Web client ID | `841057078666-fmstis3g9qm2tlp7bisf0reh69q2173l.apps.googleusercontent.com` |
| `GoogleSignIn(clientId: …)` | `app/lib/providers/auth_provider.dart` |
| iOS URL scheme (redirect) | `app/ios/Runner/Info.plist` → `CFBundleURLTypes` |
| macOS URL scheme (redirect) | `app/macos/Runner/Info.plist` → `CFBundleURLTypes` |

> ⚠️ **Never commit the client secret.** The mobile/web flow does **not** need it —
> it is only used in server-side flows. Keep it out of the repository (put it in
> `server/.env` if ever used). If you already shared it, rotate it in the console.

## Why the app crashed

The old code created `GoogleSignIn()` with no client and the native side had no
configuration:

- **iOS/macOS** — `GIDSignIn` raises a native exception when no client / redirect
  scheme is registered → the app terminates on button tap.
- **Android** — without a `google-services.json` and a registered Android client,
  sign-in returns a `DEVELOPER_ERROR` (10).

Now the plugin is configured with the **web client ID** and the redirect scheme is
registered, which removes the crash. To fully succeed, complete the steps below for
your platform.

## 1) Web client — what to fill in (the form you opened)

For the **Web application** client:

| Field | Value |
|-------|-------|
| **Authorized JavaScript origins** | `http://localhost:5000` *(Flutter Web dev server — change the port to the one `flutter run -d chrome` prints)*<br>plus your production domain, e.g. `https://translator.example.com` |
| **Authorized redirect URIs** | `http://localhost`<br>`http://localhost:5000`<br>plus `https://translator.example.com` |

Settings take effect after a few minutes to a few hours.

> On Flutter Web the plugin redirects back to the page origin, so the origin must
> be listed under **Authorized JavaScript origins**.

## 2) Testing mode (unpublished app)

1. Open **Google Cloud Console → APIs & Services → OAuth consent screen**.
2. Choose **External**, set the app name and logo, and a support email.
3. Under **Audience → Test users** add the Google accounts allowed to sign in.
   While the app is in *"Testing"* status, only these accounts can log in —
   **no app verification is required**.
4. Publish the app only when you are ready for production (then you may need a
   review depending on the scopes you request).

## 2.1) Enable the People API (required on Web)

On the **web** platform, after the token is issued, the plugin calls
`people/me` to read the profile (name, photo). If the **People API** is disabled,
this call returns `403` and sign-in fails at the very end.

1. **APIs & Services → Library**
2. Search for **“People API”**
3. Click **Enable**
4. Wait ~1 minute and sign in again

## 3) Web / Desktop

Already works after step 1. Run `flutter run -d chrome`.

## 4) Android

Google Sign-In on Android validates the **package name + SHA-1** against an
**Android** OAuth client, so:

1. In the console create an **Android** OAuth client:
   - Package name: `com.example.ai_translator`
   - SHA-1: debug fingerprint from your keystore
     ```bash
     cd android && ./gradlew signingReport
     ```
2. Download `google-services.json` and place it in `android/app/`.
3. Enable the Google services Gradle plugin in `android/app/build.gradle` and
   the root `android/build.gradle`.
4. The web client ID above is used automatically as the token audience.

## 5) iOS / macOS (единый клиент)

На Apple платформах один **iOS** OAuth-клиент работает и на iOS, и на macOS —
плагин `google_sign_in` ищет `REVERSED_CLIENT_ID` в `Info.plist` и
направляет запрос к Google. Код клиента один и тот же на обеих платформах.

### Шаг 1 — Создать iOS OAuth-клиент

1. **Google Cloud Console → APIs & Services → Credentials**
2. Нажать **+ CREATE CREDENTIALS → OAuth client ID**
3. **Application type** → **iOS**
4. Заполнить:
   | Поле | Значение |
   |------|----------|
   | **App name** | `AI Translator` *(любое имя)* |
   | **Bundle ID** | `com.example.aiTranslator` *(use exactly this — check Xcode)* |
5. Нажать **Create**
6. **Скопировать** `Client ID` — это что-то вроде `841057078666-xxxx.apps.googleusercontent.com`

### Шаг 2 — Обновить Info.plist (обе платформы)

Замените `CFBundleURLSchemes` в **обеих** файлах:

- `ios/Runner/Info.plist`
- `macos/Runner/Info.plist`

Было (Web client):
```
com.googleusercontent.apps.841057078666-fmstis3g9qm2tlp7bisf0reh69q2173l
```

Стало (iOS client — ваш новый ID):
```
com.googleusercontent.apps.841057078666-ВАШ_НОВЫЙ_ID
```

> `CFBundleURLSchemes` — это **reversed** client ID: `com.googleusercontent.apps.` + ID
> без `apps.googleusercontent.com`. Просто замените число.

> **Код менять не нужно.** На iOS/macOS нативный `GIDSignIn` читает client ID
> из `Info.plist` напрямую. Параметр `clientId:` в `GoogleSignIn()` используется
> только на Web.

### Шаг 3 — GoogleService-Info.plist (рекомендуется)

1. Скачайте `GoogleService-Info.plist` при создании iOS-клиента
2. Перетащите в `ios/Runner` в Xcode (Copy items if needed, target = Runner)
3. Для macOS: создайте **macOS** OAuth-клиент с тем же bundle ID (`com.example.aiTranslator`),
   скачайте `GoogleService-Info.plist` и добавьте в `macos/Runner`

> **Минимальный вариант**: без `GoogleService-Info.plist` вход работает —
> нативный SDK читает только `REVERSED_CLIENT_ID` из `Info.plist`.

### Шаг 4 — Test users

Убедитесь, что в **OAuth consent screen → Test users** добавлены нужные Google-аккаунты.

### Шаг 5 — Запуск

```bash
# iOS
flutter run -d <simulator_id>

# macOS
flutter run -d macos
```

Код менять не нужно — после обновления `Info.plist` вход на iOS/macOS заработает.

## 6) Quick checklist

- [ ] Web client origins/redirects filled (`http://localhost:5000` …)
- [ ] iOS OAuth client created (Bundle ID: `com.example.aiTranslator`)
- [ ] `Info.plist` updated with iOS client's reversed ID (both iOS and macOS)
- [ ] Test users added on the consent screen
- [ ] (Android) `google-services.json` + SHA-1 + Google services plugin
- [ ] (iOS) `GoogleService-Info.plist` in `ios/Runner` *(optional)*
- [ ] `flutter clean && flutter pub get`

## 7) Troubleshooting — “Error 400”

Google returns `400` when the **redirect URI / origin does not match** what the app
actually uses. The app now shows the exact reason in a snackbar — read it.

**On Web (Flutter Web / Chrome):**

1. Run with a **fixed port** and add that exact origin:
   ```bash
   flutter run -d chrome --web-port=5000
   ```
2. In the console make sure **both** fields contain `http://localhost:5000`:
   - Authorized JavaScript origins → `http://localhost:5000`
   - Authorized redirect URIs → `http://localhost:5000`
3. Use `localhost`, not `127.0.0.1` — Google treats them as different origins.
4. If you open the app at `http://127.0.0.1:5000`, add that origin too.

**On iOS / Android with a Web client:**

A **Web application** client is only for browser/desktop flows. On iOS/Android the
native Google SDK signs in with a **platform client**; reusing the Web client there
produces a `400 redirect_uri_mismatch` (the Web client has no native redirect scheme).

→ Create a proper **iOS** and/or **Android** OAuth client (section 4/5 above) and the
native flow will succeed.

**After editing the console:** changes propagate in ~5 min to a few hours.
