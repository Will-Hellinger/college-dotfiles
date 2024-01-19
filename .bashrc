source /user/local/lib/config/Bash_profile

update_dotfiles() {
  local repo_dir="$HOME/dotfiles"
  local repo_url="https://github.com/Will-Hellinger/college-dotfiles.git"

  local DOTFILES_VIMRC="$repo_dir/.vimrc"
  local HOME_VIMRC="$HOME/.vimrc"

  local DOTFILES_BASHRC="$repo_dir/.bashrc"
 	local HOME_BASHRC="$HOME/.bashrc"

  if [ ! -d "$repo_dir" ]; then
    git clone "$repo_url" "$repo_dir"
  else
    (cd "$repo_dir" && git pull origin main)
  fi

  if [ ! -L "$HOME_VIMRC" ]; then
    if [ -f "$DOTFILES_VIMRC" ]; then
      ln -s "$DOTFILES_VIMRC" "$HOME_VIMRC"
    else
      echo "dotfiles .vimrc not found. Symlink not created."
    fi
  fi

  if [ ! -L "$HOME_BASHRC" ]; then
    if [ -f "$DOTFILES_BASHRC" ]; then
      ln -s "$DOTFILES_BASHRC" "$HOME_BASHRC"
    else
      echo "dotfiles .bashrc not found. Symlink not created."
    fi
  fi
}

get_tools() {
	local fastfetch_url="https://github.com/fastfetch-cli/fastfetch/releases/download/2.6.0/fastfetch-2.6.0-Linux.zip"
	local btop_url="https://github.com/aristocratos/btop/releases/download/v1.3.0/btop-x86_64-linux-musl.tbz"
	local tools_dir="$HOME/tools"

 	mkdir -p "$tools_dir"

 	if [ ! -f "$tools_dir/fastfetch" ]; then
		echo "Downloading fastfetch..."
	
		wget -O fastfetch.zip "$fastfetch_url" || curl -L "$fastfetch_url" -o fastfetch.zip
    unzip fastfetch.zip
    rm fastfetch.zip

		mv "./fastfetch/usr/bin/fastfetch" "$tools_dir/fastfetch"
		rm -rf "fastfetch"

		echo "Done setting up fastfetch"
	fi

 	if [ ! -f "$tools_dir/btop" ]; then
  	echo "Downloading btop..."
    
		wget -O btop.tbz "$btop_url" || curl -L "$btop_url" -o btop.tbz
    tar -xjf btop.tbz
    rm btop.tbz

		mv "./btop/bin/btop" "$tools_dir/btop"
		rm -rf "btop"

		echo "done setting up btop"
	fi
 }

get_tools
update_dotfiles
fastfetch

export PATH="$HOME/tools:$PATH"
