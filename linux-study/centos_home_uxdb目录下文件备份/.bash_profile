# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

GRADLE=/usr/local/gradle/gradle-4.6/bin
PATH=$PATH:$HOME/.local/bin:$HOME/bin:$GRADLE

export PATH

export PATH="$HOME/.cargo/bin:$PATH"
