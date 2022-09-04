# Stable Diffusion Installation script for Apple Silicon CPU (M1, M1Pro, M2)

This script will help you to install Stable Diffusion on your Mac. It takes care of installing all dependencies for you and provides a menu to launch a Web UI, run in your terminal, or Upscale photos to High Definition format.

## Get Started: How to install Stable Diffusion on Apple M1 with GPU support

Paste the following command in your MacOS terminal.

Option 1: Clone the project.
```bash
git clone git@github.com:glonlas/Stable-Diffusion-Apple-Silicon-M1-Install.git

cd Stable-Diffusion-Apple-Silicon-M1-Install

./install-stable-diffusion-apple-silicon.sh
```

Option 2: Download offline copy of this repo
```bash
curl https://raw.githubusercontent.com/glonlas/Stable-Diffusion-Apple-Silicon-M1-Install/main/install-stable-diffusion-apple-silicon.sh -o install-stable-diffusion-apple-silicon.sh

./install-stable-diffusion-apple-silicon.sh
```

## How to use it?
To use it simply go to the folder where you put this project and run `./install-stable-diffusion-apple-silicon.sh`.

The script will automatically detect if all the dependencies are installed, then will display the menu to start generating or upscaling images.

**Script menu**
![Stable Diffusion Install on MacOS](https://raw.githubusercontent.com/glonlas/Stable-Diffusion-Apple-Silicon-M1-Install/main/docs/assets/menu-screenshot.png)

**Web UI provided by Lstein Stable-Diffusion project**
![Stable Diffusion Web UI](https://raw.githubusercontent.com/glonlas/Stable-Diffusion-Apple-Silicon-M1-Install/main/docs/assets/web-ui.png)

**Script detecting missing installation**
Screen you will see at first launch.
![Stable Diffusion Install on MacOS](https://raw.githubusercontent.com/glonlas/Stable-Diffusion-Apple-Silicon-M1-Install/main/docs/assets/install-screenshot.png)

## Features:
**Automatic installs**
- [x] Install Brew, Wget, Unzip, MiniConda (if not on the system)
- [x] Install Stable Diffusion project ([from Lstein Github](https://github.com/lstein/stable-diffusion))
- [x] Install Stable Diffusion 1.4 Model
- [x] Install GFPGAN ([from TencentARC Github](https://github.com/TencentARC/GFPGAN))
- [x] Install Real-ESRGAN upscaler ([from Xinntao Github](https://github.com/xinntao/Real-ESRGAN/))

**Stable Diffusion features**
- [x] Run Stable Diffusion in Terminal mode
- [x] Run Stable Diffusion in a Web UI
- [x] On-demand picture upscaling
- [x] Uninstall Stable Diffusion

## Credits
- [Lstein](https://github.com/lstein) for the Apple Silicon compatible Stable Diffusion
- [TencentARC](https://github.com/TencentARC) for GFPGAN
- Any-Winter-4079 from Reddit [for the Apple Silicon tutorial](https://www.reddit.com/r/StableDiffusion/comments/x3yf9i/stable_diffusion_and_m1_chips_chapter_2/)
- [Xinntao](https://github.com/xinntao) for Real-ESRGAN

## FAQ
### 1. Can I copy this script and update it?
Yes

### 2. Can I use and integrate it in my project (personal or commercial)?
Yes you can

### 3. Can I send Pull request to improve it?
Yes, Absolutely this small project is made to help anyone to play with Stable Diffusion. Feel free to contribute

### 4. Where all the projects are installed?
Per default, if you do not update the variable in the script, it is installed in `$HOME/stable-diffusion`
