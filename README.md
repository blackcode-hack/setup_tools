# Installation
git clone https://github.com/blackcode-hack/setup_tools.sh

cd setup_tools.sh 

chmod +x setup_tools.sh

./setup_tools.sh

# After finishing install past go path on ~/.bashrc or ~/.zshrc
# But first how can i now which path i use ....?
## answer is
echo $0    <--------------- show you which path you use 
# Then past this in last line 
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Then active this by doing 
source ~/.bashrc  or  ~/.zshrc
