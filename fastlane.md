# Fastlane 설정 및 사용법

## 설정된 내용

- iOS 및 Android 프로젝트에 `fastlane`을 기본 설정했습니다.
- 각 플랫폼별로 `beta` lane을 생성하여 TestFlight (iOS) 및 Google Play Store (Android)에 배포할 수 있도록 설정했습니다.
- 민감한 정보를 `fastlane_config.json` 파일로 분리하여 저장하도록 설정했습니다.

## 사용법

### 1. iOS 배포 설정

- `sudoku/ios/fastlane/fastlane_config.json` 파일을 열어 App Store Connect API Key 정보를 입력합니다.
- 자세한 내용은 [fastlane iOS 설정 문서](https://docs.fastlane.tools/getting-started/ios/setup/)를 참고하세요.

### 2. Android 배포 설정

- `sudoku/android/fastlane/fastlane_config.json` 파일을 열어 Google Play Console의 JSON key 파일 경로와 패키지 이름을 입력합니다.
- 자세한 내용은 [fastlane Android 설정 문서](https://docs.fastlane.tools/getting-started/android/setup/)를 참고하세요.

### 3. 배포 실행

- 설정이 완료되면 다음 명령어를 사용하여 앱을 배포할 수 있습니다.

#### iOS

```bash
cd /Users/dirmich/work/0.ai/sudoku/sudoku/ios
fastlane beta
```

#### Android

```bash
cd /Users/dirmich/work/0.ai/sudoku/sudoku/android
fastlane beta
```