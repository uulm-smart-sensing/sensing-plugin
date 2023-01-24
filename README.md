<a name="readme-top"></a>

# sensing_plugin

The sensing plugin for the Smart Sensing Library

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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
