# sensing_plugin

The sensing plugin for the Smart Sensing Library

## Getting Started

1. Clone the repo

    ```bash
    git clone https://gitlab.uni-ulm.de/se-anwendungsprojekt-22-23/sensing-plugin.git
    ```

2. Execute setup script

    On Windows run:

    ```powershell
    .\setup.ps1
    ```

    On Linux/macOS run:

    ```bash
    bash setup.sh
    ```

3. Your setup is now complete and you're good to go.

## Keeping Pigeon code up to date

Pigeon is a plugin that generates API code for all three of our platforms (Dart, Android, iOS).
The API code is defined in the `./pigeons` directory. If the content changes, run the following command to keep the code up to date.

On Windows run:

```powershell
.\run_pigeon.ps1
```

On Linux/macOS run:

```bash
bash run_pigeon.sh
```

## Working on Android

We use Android Studio to write code for our Android sensor implementations.
In order for Android Studio to recognize all dependencies, it is mandatory to open the `./example/android/` directory with Android Studio. If any other directory is opened, the dependencies won't be recognized.

### Linting

We use [Ktlint](https://pinterest.github.io/ktlint/) to lint our Kotlin code.

For a simple check, run:

```bash
./gradlew ktlintCheck
```

For Ktlint to format the code automatically, run:

```bash
./gradlew ktlintFormat
```

## Working on iOS

For the development of the iOS plaform code, which is written in Swift, we use Xcode.
In order for Xcode to recognize all dependencies and correctly set up the project structure, it is mandatory to open the `./example/ios/` directory with Xcode.

### Linting

To lint the Swift code we use [Swiftlint](https://github.com/realm/SwiftLint) (see [here](https://github.com/realm/SwiftLint#installation) for installation guide).
If *Swiftlint* is installed successfully, you can manually check the Swift files by running

```bash
swiftlint
```
and correct fixable linting issues with

```bash
swiftlint --fix
```

For further configuration of the `swiftlint` command, it is recommended to use a `.swiftlint.yml` file, which already exist in this repository and can be extended.

---

If you want *Swiftlint* automatically be runned by Xcode, you need to set up a new "Run script phase" in the "Build phases" of your target and execute the `swiftlint` command there, like described [here](https://github.com/realm/SwiftLint#xcode).
