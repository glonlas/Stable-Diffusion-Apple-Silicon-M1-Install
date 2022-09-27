#!/bin/bash

# This script install Stable Diffusion on Apple Silicon M1 M1Pro CPU.

# -- Variables you can change ---------------------------------------------------------------------
# 1. URL to Github project and model
INVOKEAI_GITHUB_URL="https://github.com/invoke-ai/InvokeAI/archive/refs/heads/main.zip"
LDM_MODEL_URL="https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media"
GFPGAN_GITHUB_URL="https://github.com/TencentARC/GFPGAN/archive/refs/heads/master.zip"
GFPGAN_MODEL_URL="https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth"
CODEFORMER_MODEL_URL="https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth"
REALESRGAN_GITHUB_URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-macos.zip"

# 2. Path where projects will be installed
# Per default:
# project root folder will be in ~/stable-diffusion/
SD_PATH="$HOME/stable-diffusion"

# lstein/stable-diffusion will be in ~/stable-diffusion/stable-diffusion
INVOKEAI_FOLDER_NAME="InvokeAI"
INVOKEAI_PATH="$SD_PATH/$INVOKEAI_FOLDER_NAME"
LDM_PATH="$INVOKEAI_PATH/models/ldm/stable-diffusion-v1"
GFPGAN_MODEL_PATH="$INVOKEAI_PATH/src/gfpgan/experiments/pretrained_models"
CODEFORMER_MODEL_PATH="$INVOKEAI_PATH/ldm/dream/restoration/codeformer/weights/"

# Real ESRGAN will be in ~/stable-diffusion/realesrgan
REALESRGAN_PATH="$SD_PATH/realesrgan"

CONDA_ENV="ldm"
CONDA_ENV_BAK=$CONDA_ENV"_bak"

# -- SCRIPT VERSION -------------------------------------------------------------------------------
SCRIPT_VERSION="0.1.3"
PROJECT_URL="https://github.com/glonlas/Stable-Diffusion-Apple-Silicon-M1-Install"

# -- Terminal color settings ----------------------------------------------------------------------
TITLE="\033[1m\033[36m"
ITEM="\033[0\033[34m"
ALERT="\033[0\033[31m"
WARNING="\033[0\033[33m"
SUCCESS="\033[1m\033[32m"
RESET="\033[0m\033[39m"

# -- FUNCTIONS -----------------------------------------------------------------------------------
STABLE_DIFFUSION_IS_INSTALLED=1

function check_OS() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ $(uname -m) != 'arm64' ]]; then
            echo -e "${ALERT}Apple CPU not supported${RESET}"
            echo "We are sorry, but this script supports only Apple Silicon CPU (M1, M1Pro, ...)"
            exit 1
        fi
    else
        echo -e "${ALERT}OS not supported${RESET}"
        echo "We are sorry, but this script supports only Apple Silicon with MacOS 12.4."
        exit 1
    fi
}

function check_install() {
    if ! check_conda_env $CONDA_ENV
    then
        STABLE_DIFFUSION_IS_INSTALLED=0
    fi 

    if [ ! -d $LDM_PATH ]
    then
        STABLE_DIFFUSION_IS_INSTALLED=0
    fi   
}

function install_dependencies() {
    # Check if Brew is missing, then install it
    if ! command -v brew &> /dev/null
    then
        echo -e "${ITEM}- Install Brew${RESET}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${SUCCESS}- Brew already installed${RESET}"
    fi

    # Check if Unzip is missing, then install it
    if ! command -v unzip &> /dev/null
    then
        echo -e "${ITEM}- Install unzip${RESET}"
        brew install -f unzip &> /dev/null
    else
        echo -e "${SUCCESS}- unzip already installed${RESET}"
    fi
    
    # Check if Wget is missing, then install it
    if ! command -v wget &> /dev/null
    then
        echo -e "${ITEM}- Install wget${RESET}"
        brew install -f wget &> /dev/null
    else
        echo -e "${SUCCESS}- wget already installed${RESET}"
    fi

    # Check if Conda is missing, then install it
    if ! command -v conda &> /dev/null
    then
        echo -e "${ITEM}- Install Miniconda${RESET}"
        brew install -f --cask miniconda &> /dev/null
    else
        echo -e "${SUCCESS}- Miniconda already installed${RESET}"
    fi
}

function install_stable_diffusion() {
    INVOKEAI_ARCHIVE="$INVOKEAI_FOLDER_NAME.zip"
    mkdir $SD_PATH
    cd $SD_PATH

    echo -e "${ITEM}- Download InvokeAI Project${RESET}"
    wget -q --show-progress $INVOKEAI_GITHUB_URL -O $INVOKEAI_ARCHIVE

    echo -e "${ITEM}- Install InvokeAi Project${RESET}"
    unzip $INVOKEAI_ARCHIVE &> /dev/null
    rm $INVOKEAI_ARCHIVE &> /dev/null
    mv $INVOKEAI_FOLDER_NAME-main $INVOKEAI_FOLDER_NAME

    echo -e "${ITEM}- Download LDM Model${RESET}"
    mkdir -p $LDM_PATH
    cd $LDM_PATH
    wget -q --show-progress $LDM_MODEL_URL -O model.ckpt

    echo -e "${ITEM}- Download GFPGAN Model${RESET}"
    mkdir -p $GFPGAN_MODEL_PATH
    wget -q --show-progress $GFPGAN_MODEL_URL -P $GFPGAN_MODEL_PATH 

    echo -e "${ITEM}- Download CodeFormer Model${RESET}"
    mkdir -p $GFPGAN_MODEL_PATH
    wget -q --show-progress $CODEFORMER_MODEL_URL -P $CODEFORMER_MODEL_PATH 
}

function install_Real_ESRGAN_upscaler() {
    REALESRGAN_ARCHIVE="realesrgan.zip"
    mkdir $REALESRGAN_PATH
    cd $REALESRGAN_PATH

    echo -e "${ITEM}- Download Real-ESRGAN Project${RESET}"
    wget -q --show-progress $REALESRGAN_GITHUB_URL -O $REALESRGAN_ARCHIVE
    unzip $REALESRGAN_ARCHIVE &> /dev/null
    rm $REALESRGAN_ARCHIVE &> /dev/null
    chmod u+x $REALESRGAN_PATH/realesrgan-ncnn-vulkan
    echo -e "${SUCCESS}- Real-ESRGAN is installed in $REALESRGAN_PATH ${RESET}"
    echo -e "${WARNING}Because MacOS cannot verify the developer of “realesrgan-ncnn-vulkan”. MacOS will ask you if you want to trust it the first time your will use it.${RESET}"
    echo "If you do not want this tool on your system, feel free to delete the folder $REALESRGAN_PATH"
}

function check_Real_ESRGAN() {
    # Check if Brew is missing, then install it
    if ! command -v $REALESRGAN_PATH/realesrgan-ncnn-vulkan &> /dev/null
    then
        echo -e "${ALERT}Real_ESRGAN upscaler not found${RESET}"
        echo ""
        echo -e "${TITLE}Install Real_ESRGAN upscaler${RESET}"
        install_Real_ESRGAN_upscaler
    fi
}

function check_conda_env(){
    conda env list | grep -w "${@}" >/dev/null 2>/dev/null
}

function init_conda_env(){
    CONDA_BASE=$(conda info --base)
    source $CONDA_BASE/etc/profile.d/conda.sh
}

function activate_env() {
    init_conda_env
    conda activate $CONDA_ENV
}

function deactivate_env() {
    init_conda_env
    conda deactivate
}

function create_env() {
    if check_conda_env $CONDA_ENV
    then
        echo ""
        echo -e "${ALERT}Conda '$CONDA_ENV' env exist already${RESET}"
        echo ""
        echo "What do you want to do?"
        echo "   1) Remove current '$CONDA_ENV' env and install the new one"
        echo "   2) Rename the current '$CONDA_ENV' to '$CONDA_ENV_BAK' and install the new one"
        echo "   3) Skip this install and keep the current '$CONDA_ENV' env"
        until [[ ${ENV_MENU_OPTION} =~ ^[1-3]$ ]]; do
            read -rp "Select an option [1-3]: " ENV_MENU_OPTION
        done
        case "${ENV_MENU_OPTION}" in
        1)
            delete_env
            install_env
            ;;
        2)
            rename_env
            install_env
            ;;
        esac
    else
        install_env
    fi
}

function delete_env(){
    deactivate_env
    conda env remove -n $CONDA_ENV
    echo -e "${SUCCESS} - Conda env $CONDA_ENV deleted${RESET}"
}

function install_env() {
    echo -e "${ITEM} - Creating the new Conda env $CONDA_ENV${RESET}"
    cd $INVOKEAI_PATH
    PIP_EXISTS_ACTION=w CONDA_SUBDIR=osx-arm64 conda env create -f environment-mac.yaml

    activate_env

    python3 -m pip install --upgrade pip

    # Fix hack: Ensure that the pip component from Github project in the environment-mac.yaml 
    # are fully installed
    pip install -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers
    pip install -e git+https://github.com/openai/CLIP.git@main#egg=clip
    pip install -e git+https://github.com/Birch-san/k-diffusion.git@mps#egg=k_diffusion

    echo -e "${SUCCESS} - Conda env $CONDA_ENV installed ${RESET}"
    deactivate_env
}

function rename_env() {
    deactivate_env
    echo -e "${ITEM} - Renaming the Conda env $CONDA_ENV to $CONDA_ENV_BAK ${RESET}"
    conda rename -n $CONDA_ENV -d $CONDA_ENV_BAK
    echo -e "${SUCCESS} - Conda env $CONDA_ENV renamed to $CONDA_ENV_BAK ${RESET}"
}

function setup_GFPGAN {
    activate_env
    cd $INVOKEAI_PATH
    pip install basicsr
    pip install facexlib
    pip install realesrgan

    python3 scripts/preload_models.py
    deactivate_env
}

function congratulation_msg(){
    echo ""
    echo -e "${SUCCESS}Congratulation! Your environment is installed${RESET}"
    echo ""
}

# -- INSTALL FLOW ---------------------------------------------------------------------------------
function install() {
    echo ""
    echo -e "${TITLE}1. Install missing dependencies ${RESET}"
    install_dependencies

    echo ""
    echo -e "${TITLE}2. Download Stable-diffusion project and Model weights ${RESET}"
    install_stable_diffusion

    echo ""
    echo -e "${TITLE}3. Create Conda Env '$CONDA_ENV' ${RESET}"
    create_env

    echo ""
    echo -e "${TITLE}4. Setup GFPGAN ${RESET}"
    setup_GFPGAN

    congratulation_msg
}

function uninstall() {
    echo ""
    echo -e "${ALERT}Uninstalling Stable Diffusion and Conda Env.${RESET}"

    read -p "Do you want to remove $SD_PATH? [y/N]: " RM_SD_FOLDER
    RM_SD_FOLDER=${RM_SD_FOLDER:-"n"}
    if [[ $RM_SD_FOLDER == 'y' || $RM_SD_FOLDER == 'Y' ]]; then
        rm -rf $SD_PATH
        echo -e "${ITEM} - $SD_PATH deleted${RESET}"
    fi

    read -p "Do you want to remove Conda env '$CONDA_ENV'? [y/N]: " RM_CONDA_ENV
    RM_CONDA_ENV=${RM_CONDA_ENV:-"n"}
    if [[ $RM_CONDA_ENV == 'y' || $RM_CONDA_ENV == 'Y' ]]
    then
        delete_env
    fi

    echo ""
    echo ""
}

# -- Script Run functions ------------------------------------------------------------------------------
function run_in_browser() {
    echo -e "${ITEM}Starting Stable Diffusion Web UI${RESET}"
    cd $INVOKEAI_PATH
    activate_env
    open http://localhost:9090/
    echo "Reload your browser page once the command below will be showing 'Started Stable Diffusion dream server!'"
    python3 scripts/dream.py --web
    
}

function run_in_terminal() {
    echo -e "${ITEM}Starting Stable Diffusion in this terminal${RESET}"
    cd $INVOKEAI_PATH
    activate_env
    python3 ./scripts/dream.py
}

function upscale_picture() {
    # Check if Real ESRGAN is installed
    check_Real_ESRGAN

    UPSCALED_IMG_PATH=$INVOKEAI_PATH/outputs

    echo ""
    echo -e "${TITLE}Upscale a picture with Real-ESRGAN upscaler${RESET}"
    read -p "Path to the picture to upscale: " INPUT_FILE_PATH
    
    echo ""
    read -p "Where to save the picture? [Default: $UPSCALED_IMG_PATH]: " DEST_PATH
    DEST_PATH=${FILEPATH:-${UPSCALED_IMG_PATH}}
    DEST_FILE_NAME="HD_$(basename "$INPUT_FILE_PATH")"
    DEST_FILE=$DEST_PATH/$DEST_FILE_NAME

    echo ""
    echo -e "Upscaler model available: ${ITEM}realesr-animevideov3${RESET} | ${ITEM}realesrgan-x4plus${RESET} | ${ITEM}realesrgan-x4plus-anime${RESET} | ${ITEM}realesrnet-x4plus${RESET}"
    read -p "Upscaler model to use [default: realesrgan-x4plus]: " UPSCALER_MODEL
    UPSCALER_MODEL=${UPSCALER_MODEL:-"realesrgan-x4plus"}

    echo ""
    echo -e "${ITEM}Start upscaling${RESET}"
    # To work you need to be in the folder first then execute it
    # Issue: https://github.com/xinntao/Real-ESRGAN/issues/379
    cd $REALESRGAN_PATH
    ./realesrgan-ncnn-vulkan -i "$INPUT_FILE_PATH" -o "$DEST_FILE" -n "$UPSCALER_MODEL"

    echo -e "${SUCCESS}Picture successfully upscaled in${RESET} $DEST_FILE"
}

# -- MAIN -----------------------------------------------------------------------------------------
function main() {
    echo ""
    echo ""
    echo "+-----------------------------------------+"
    echo "|                                         |"
    echo -e "|${TITLE}     Stable Diffusion Apple Silicon      ${RESET}|"
    echo -e "|${TITLE}             Install script              ${RESET}|"
    echo "|                                         |"
    echo "+-----------------------------------------+"
    echo "Script Version: $SCRIPT_VERSION"
    echo "Source of the script: $PROJECT_URL"

    # Check we are on the right system before to start
    check_OS

    # Check if everything is install before to start
    check_install
    if [[ $STABLE_DIFFUSION_IS_INSTALLED == 0 ]]
    then
        echo ""
        echo -e "${ALERT}Stable Diffusion is not installed${RESET}"
        read -p "Do you want to install Stable Diffusion? [Y/n]: " INSTALL_SD
        INSTALL_SD=${INSTALL_SD:-"y"}
        if [[ $INSTALL_SD == 'y' || $INSTALL_SD == 'Y' ]]; then
            echo -e "${ITEM}Starting installation${RESET}"
            install
        fi
    fi

    echo ""
    echo "What do you want to do?"
    echo "   1) Install Stable Diffusion"
    echo "   2) Run Stable Diffusion in Browser"
    echo "   3) Run Stable Diffusion in Terminal"
    echo "   4) Upscale a picture with Real-ESRGAN upscaler"
    echo "   5) Uninstall Stable Diffusion"
    echo "   6) Exit"

    until [[ ${MENU_OPTION} =~ ^[1-6]$ ]]; do
        read -rp "Select an option [1-6]: " MENU_OPTION
    done
    case "${MENU_OPTION}" in
    1)
        install
        ;;
    2)
        run_in_browser
        ;;
    3)
        run_in_terminal
        ;;
    4)
        upscale_picture
        ;;
    5)
        uninstall
        ;;
    6)
        deactivate_env &> /dev/null 
        exit 1
        ;;
    esac
}

main
