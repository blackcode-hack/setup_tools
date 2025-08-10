#!/bin/bash

# Smart Recon Setup Script for Kali Linux
# This script will install all dependencies and tools needed for Smart_recon.py

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${GREEN}"
cat << "EOF"
 █████╗ ███╗   ██╗ ██████╗ ██╗   ██╗██████╗ ███████╗███████╗
██╔══██╗████╗  ██║██╔═══██╗██║   ██║██╔══██╗██╔════╝██╔════╝
███████║██╔██╗ ██║██║   ██║██║   ██║██║████║█████╗  ███████╗
██╔══██║██║╚██╗██║██║   ██║██║   ██║██║  ██║██╔══╝  ╚════██║
██║  ██║██║ ╚████║╚██████╔╝╚██████╔╝██████╔╝███████╗███████║
╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
        👑 anoubes back - Smart Recon & Stealth 👑
EOF
echo -e "${NC}"

echo -e "${BLUE}🚀 Smart Recon Setup Script for Kali Linux${NC}"
echo "=================================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${YELLOW}⚠️  Running as root. This is not recommended for security reasons.${NC}"
   read -p "Continue anyway? (y/n): " -n 1 -r
   echo
   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
       exit 1
   fi
fi

# Check if running on Kali Linux
if ! grep -q "kali" /etc/os-release 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Not running on Kali Linux. Some features may not work properly.${NC}"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ Kali Linux detected${NC}"
fi

# Function to run commands with error handling
run_command() {
    local cmd="$1"
    local description="$2"
    
    echo -e "${BLUE}🔄 $description...${NC}"
    if eval "$cmd"; then
        echo -e "${GREEN}✅ $description - Success${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - Failed${NC}"
        return 1
    fi
}

# Update package list
run_command "sudo apt update" "Updating package list"

# Install system packages
echo -e "${BLUE}📦 Installing system packages...${NC}"
packages="git curl wget python3-pip python3-venv build-essential pkg-config"
run_command "sudo apt install -y $packages" "Installing system packages"

# Install Go
echo -e "${BLUE}🔧 Installing Go...${NC}"
if ! command -v go &> /dev/null; then
    # Download and install Go
    run_command "curl -LO https://go.dev/dl/go1.21.5.linux-amd64.tar.gz" "Downloading Go"
    run_command "sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz" "Installing Go"
    run_command "rm go1.21.5.linux-amd64.tar.gz" "Cleaning up Go download"
    
    # Add Go to PATH
    if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo -e "${GREEN}✅ Go PATH added to ~/.bashrc${NC}"
    fi
    
    # Export for current session
    export PATH=$PATH:/usr/local/go/bin
    echo -e "${GREEN}✅ Go installed successfully${NC}"
else
    echo -e "${GREEN}✅ Go already installed${NC}"
fi

# Setup Go environment
echo -e "${BLUE}🔧 Setting up Go environment...${NC}"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Create Go directories
mkdir -p $GOPATH/bin
echo -e "${GREEN}✅ Go directories created${NC}"

# Add Go environment to bashrc (if not already added)
if ! grep -q "export GOPATH" ~/.bashrc; then
    bashrc_content="
# Go environment
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOPATH/bin
"
    echo "$bashrc_content" >> ~/.bashrc
    echo -e "${GREEN}✅ Go environment added to ~/.bashrc${NC}"
else
    echo -e "${YELLOW}⚠️  Go environment already in ~/.bashrc${NC}"
fi

# Install Python dependencies
echo -e "${BLUE}🐍 Installing Python dependencies...${NC}"

# Create virtual environment
echo -e "${BLUE}🔧 Creating Python virtual environment...${NC}"
if [ ! -d "venv" ]; then
    run_command "python3 -m venv venv" "Creating virtual environment"
else
    echo -e "${GREEN}✅ Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "${BLUE}🔧 Activating virtual environment...${NC}"
source venv/bin/activate
echo -e "${GREEN}✅ Virtual environment activated${NC}"

# Upgrade pip in virtual environment
run_command "pip install --upgrade pip" "Upgrading pip"

# Install Python packages in virtual environment
if [ -f "requirements.txt" ]; then
    run_command "pip install -r requirements.txt" "Installing Python packages"
else
    echo -e "${YELLOW}⚠️  requirements.txt not found, installing basic packages...${NC}"
    basic_packages="requests urllib3 beautifulsoup4 lxml dnspython colorama rich"
    for package in $basic_packages; do
        run_command "pip install $package" "Installing $package"
    done
fi

# Install Go security tools
echo -e "${BLUE}🔨 Installing Go security tools...${NC}"
go_tools=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    "github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
    "github.com/tomnomnom/assetfinder@latest"
    "github.com/tomnomnom/waybackurls@latest"
    "github.com/tomnomnom/gf@latest"
    "github.com/tomnomnom/anew@latest"
    "github.com/lc/gau/v2/cmd/gau@latest"
    "github.com/hahwul/dalfox/v2@latest"
    "github.com/003random/getJS@latest"
)

# Install tools and copy to system-wide location
for tool in "${go_tools[@]}"; do
    tool_name=$(echo $tool | awk -F'/' '{print $NF}' | sed 's/@.*//')
    run_command "go install -v $tool" "Installing $tool_name"
    
    # Copy tool to /usr/local/bin for system-wide access
    if [ -f "$GOPATH/bin/$tool_name" ]; then
        run_command "sudo cp $GOPATH/bin/$tool_name /usr/local/bin/" "Copying $tool_name to /usr/local/bin"
        run_command "sudo chmod +x /usr/local/bin/$tool_name" "Making $tool_name executable"
    else
        echo -e "${YELLOW}⚠️  $tool_name not found in $GOPATH/bin${NC}"
    fi
done

echo -e "${GREEN}✅ All Go tools copied to /usr/local/bin for system-wide access${NC}"

# Create tools directory and copy all tools
echo -e "${BLUE}📁 Creating tools directory...${NC}"
run_command "sudo mkdir -p /opt/smart_recon_tools" "Creating tools directory"
run_command "sudo chmod 755 /opt/smart_recon_tools" "Setting permissions on tools directory"

# Copy all Go tools to tools directory
echo -e "${BLUE}📋 Copying all tools to /opt/smart_recon_tools...${NC}"
for tool in "${go_tools[@]}"; do
    tool_name=$(echo $tool | awk -F'/' '{print $NF}' | sed 's/@.*//')
    if [ -f "$GOPATH/bin/$tool_name" ]; then
        run_command "sudo cp $GOPATH/bin/$tool_name /opt/smart_recon_tools/" "Copying $tool_name to tools directory"
    fi
done

# Install findomain
echo -e "${BLUE}🔍 Installing findomain...${NC}"
run_command "curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux" "Downloading findomain"
run_command "chmod +x findomain-linux" "Making findomain executable"
run_command "sudo mv findomain-linux /usr/local/bin/findomain" "Moving findomain to /usr/local/bin"
run_command "sudo cp /usr/local/bin/findomain /opt/smart_recon_tools/" "Copying findomain to tools directory"

# Install uro
echo -e "${BLUE}🔗 Installing uro...${NC}"
run_command "pip install uro" "Installing uro"

# Setup GF patterns
echo -e "${BLUE}🎯 Setting up GF patterns...${NC}"
if [ ! -d ~/.gf ]; then
    run_command "git clone https://github.com/1ndianl33t/Gf-Patterns ~/.gf" "Cloning GF patterns"
else
    echo -e "${GREEN}✅ GF patterns already installed${NC}"
fi

# Make script executable
if [ -f "Smart_recon.py" ]; then
    run_command "chmod +x Smart_recon.py" "Making Smart_recon.py executable"
fi

# Test installation
echo -e "${BLUE}🧪 Testing installation...${NC}"
tools_to_test=("subfinder" "httpx" "nuclei" "assetfinder" "waybackurls" "gf" "anew" "gau" "dalfox" "getjs" "findomain")

missing_tools=()
for tool in "${tools_to_test[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [ ${#missing_tools[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All tools installed successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Missing tools: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}You may need to restart your terminal or run: source ~/.bashrc${NC}"
fi

# Final instructions
echo -e "${GREEN}"
echo "🎉 Installation completed successfully!"
echo ""
echo "📖 Usage:"
echo "  # Activate virtual environment first:"
echo "  source venv/bin/activate"
echo "  # Then run Smart_recon:"
echo "  python Smart_recon.py example.com"
echo "  sudo python Smart_recon.py example.com  # For stealth mode"
echo ""
echo "📚 For more information, see README.md"
echo ""
echo "💡 Tip: Restart your terminal or run 'source ~/.bashrc' to ensure all tools are in your PATH"
echo "💡 Tip: Always activate the virtual environment with 'source venv/bin/activate' before running Smart_recon"
echo ""
echo "📁 Tools installed in:"
echo "  /usr/local/bin/ - System-wide access (recommended)"
echo "  /opt/smart_recon_tools/ - Centralized tools directory"
echo ""
echo "🔧 To run tools from root or any user:"
echo "  subfinder -d example.com"
echo "  httpx -l subdomains.txt"
echo "  nuclei -u https://example.com"
echo -e "${NC}" 