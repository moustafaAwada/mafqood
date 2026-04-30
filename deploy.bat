@echo off
echo [1/2] Building Release APK...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo Build failed!
    exit /b %errorlevel%
)
echo [2/2] Distributing to Firebase...
call firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-release.apk" --app "1:695763216125:android:15724f0884943dfbea8094" --testers "hishamsayed995@gmail.com" --release-notes "New update from Asem (Automated via Antigravity)"
echo Done! Your friend should receive a notification shortly.
