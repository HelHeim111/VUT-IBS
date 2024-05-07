# Color Sequence Game
This is a documentation for a Color Sequence Game, which is a part of bachelor's thesis on topic "Game Development for Assessment of Human Memory, Attention and Reflexes". The game is implemented to test and improve the user's memory, attention and reflexes. It has graphs with user statistics to track progress. The application has a function of creating your own account, which serves to save data about the player's games.
## Table of contents
1. [Dependencies](#dependencies)
1. [Build Instructions](#build-instructions)
1. [How to Play](#how-to-play)

## Dependencies
- Flutter v3.19.2
- Dart v3.3.0
- Firebase core v2.27.1
- Firebase Auth v4.17.6
- Cloud Firestore v4.15.9

## Build instructions
As this application is specifically designed for Android devices, first try to navigate to the folder 'color_sequence_game/build/app/outputs/flutter-apk/' and locate the **.apk** files. Run the file with the corresponding architecture on your Android device, and the application should be ready to use. If those files are not located in the aforementioned folder, follow these steps:
1. Navigate to the folder 'color_sequence_game/' using cmd.
1. Run the command **flutter build apk --split-per-abi** (before running this command you should have Flutter installed).
1. Navigate to the folder 'color_sequence_game/build/app/outputs/flutter-apk/' and find the **.apk** files.
1. Run the **.apk** file with the corresponding architecture on your Android device.
1. The application is now ready to use.

## How to play
After opening the application you will be able to register a new account, you can play without it, but in this case the data of your success and progress will not be saved. To play the game itself, open the game page using the navigation at the bottom of the screen. Instructions for the game:
1. Memorize the Sequence: Watch carefully as a series of blue squares light up on the screen. These squares indicate the sequence you need to remember. Pay close attention to the order in which they appear.
1. Quick Response: Once a new set of three squares lights up, quickly tap anywhere on the playing field. This step tests your reflexes and the speed of your response.
1. Recreate the Sequence: After the entire sequence of blue squares has been shown, begin tapping the squares in the exact order they were illuminated. This part of the game assesses your memory and ability to recall the sequence correctly.
1. Minimize Errors: Attempt to replicate the sequence as accurately as possible.
1. Have fun!