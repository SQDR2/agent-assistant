@echo off
echo Testing Flutter System Tray on Windows...
echo.
echo Building Flutter app...
flutter build windows --release
echo.
echo Starting the app...
echo Please test the following:
echo 1. Check if system tray icon appears
echo 2. Try left-clicking the system tray icon
echo 3. Try right-clicking the system tray icon
echo 4. Check if context menu appears on right-click
echo 5. Test menu items functionality
echo.
echo Press any key to start the app...
pause > nul
start "" "build\windows\x64\runner\Release\flutterclient.exe"
echo.
echo App started. Check the system tray area (bottom-right corner).
echo Press any key to exit this script...
pause > nul
