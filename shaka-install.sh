#!/bin/bash

# Function to check and install dependencies
install_dependencies() {
    local os
    os=$(uname -s)

    if ! command -v curl &>/dev/null; then
        echo -e "\e[31mcurl\e[0m is not installed. Installing curl..."
        case $os in
        "Linux")
            sudo apt-get update && sudo apt-get install -y curl
            ;;
        "Darwin") # macOS
            brew install curl
            ;;
        *)
            echo "Unsupported OS: $os"
            exit 1
            ;;
        esac
    fi

    if ! command -v jq &>/dev/null; then
        echo -e "\e[31mjq\e[0m is not installed. Installing jq..."
        case $os in
        "Linux")
            sudo apt-get update && sudo apt-get install -y jq
            ;;
        "Darwin") # macOS
            brew install jq
            ;;
        *)
            echo "Unsupported OS: $os"
            exit 1
            ;;
        esac
    fi
}

# Function to get the latest release version of Shaka Packager
get_latest_version() {
    local version
    version=$(curl -s https://api.github.com/repos/shaka-project/shaka-packager/releases/latest | jq -r '.tag_name')
    echo "$version"
}

# Function to download and install Shaka Packager
install_shaka_packager() {
    local version=$1
    local os
    os=$(uname -s)
    local download_url=""

    echo "Installing Shaka Packager version \e[32m$version\e[0m"

    case $os in
    "Linux")
        download_url="https://github.com/shaka-project/shaka-packager/releases/download/$version/packager-linux-x64"
        ;;
    "Darwin") # macOS
        download_url="https://github.com/shaka-project/shaka-packager/releases/download/$version/packager-osx-arm64"
        ;;
    *)
        echo "Unsupported OS: $os"
        exit 1
        ;;
    esac

    if [[ -z "$download_url" ]]; then
        echo "Download URL not found for OS: $os"
        exit 1
    fi

    echo "Downloading Shaka Packager..."
    wget -O shaka-packager "$download_url"

    # Make it executable
    chmod +x shaka-packager

    # Check if already installed packager & remove it
    if [ -f /usr/local/bin/shaka-packager ]; then
        sudo rm /usr/local/bin/shaka-packager
    fi

    # Move it to /usr/local/bin
    sudo mv shaka-packager /usr/local/bin

    # Check if packager is installed
    shaka-packager --version
    echo "Shaka Packager installed successfully"
}

# Main function
main() {
    install_dependencies
    local latest_version
    latest_version=$(get_latest_version)
    install_shaka_packager "$latest_version"
}

# Run main function
main
