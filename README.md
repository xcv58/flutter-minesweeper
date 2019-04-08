# Flutter Minesweeper

A Flutter Minesweeper game.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Install on Real Device(s)

To install on real device(s). Please make sure your device is connected to develop machine.
For iOS you need to log in a valid iOS developer account to doe [code signing](https://developer.apple.com/support/code-signing/).

Then run below command to install on the device:

```bash
flutter run --release -d <deviceId>
```

## Development Reference

This project uses an array of int to represent the state:

```dart
//   9, checked cell with no neighbor bomb
// 1-8, checked cell with the number of neighbor bombs
//   0, unchecked
//  -1, unchecked bomb
//  -2, marked bomb correct
//  -3, marked bomb incorrect
//  -4, clicked bomb fail the game
```
