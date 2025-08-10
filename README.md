# Installation
git clone https://github.com/blackcode-hack/setup_tools

cd setup_tools

chmod +x setup_tools.sh

./setup_tools.sh
_________________________________________________________________________
# First how can i now which path i use ....?

## answer is

echo $0           <--------------- show you which path you use 

sudo nano ~/.bashrc  (##or)  ~/.zshrc
_________________________________________________________________________
# Then past this in last line 
export GOROOT=/usr/local/go

export GOPATH=$HOME/go

export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

_________________________________________________________________________

# Then active this by doing 

source ~/.bashrc   (##or)   ~/.zshrc
_________________________________________________________________________
