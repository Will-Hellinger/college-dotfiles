source /usr/local/lib/config/Bash_Profile

update_dotfiles() {
  local repo_dir="$HOME/.dotfiles"
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

  if [ -f "$HOME_VIMRC" ] && [ ! -L "$HOME_VIMRC" ]; then
    mv "$HOME_VIMRC" "$HOME_VIMRC.bak"
  fi

  if [ ! -L "$HOME_VIMRC" ]; then
    if [ -f "$DOTFILES_VIMRC" ]; then
      ln -s "$DOTFILES_VIMRC" "$HOME_VIMRC"
    else
      echo "dotfiles .vimrc not found. Symlink not created."
    fi
  fi

  if [ ! -d ~/.vim ]; then
    echo "vim plugin folder not located | Installing now..."

    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  if [ -f "$HOME_BASHRC" ] && [ ! -L "$HOME_BASHRC" ]; then
    mv "$HOME_BASHRC" "${HOME_BASHRC}.bak"
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
  local tools_dir="$HOME/.tools"

  mkdir -p "$tools_dir"

  if [ ! -f "$tools_dir/fastfetch" ]; then
    echo "Downloading fastfetch..."
	
    wget -O fastfetch.zip "$fastfetch_url" || curl -L "$fastfetch_url" -o fastfetch.zip
    unzip fastfetch.zip
    rm fastfetch.zip

    mv "./fastfetch-2.6.0-Linux/usr/bin/fastfetch" "$tools_dir/fastfetch"
    rm -rf "fastfetch-2.6.0-Linux"

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

  export PATH="$tools_dir:$PATH"
}

userlist() {
  local option=${1:-all}
  local online_users=$(who | cut -d' ' -f1 | sort | uniq)
  local all_users=$(awk -F':' '{print $1}' /etc/passwd)

  case "$option" in
    online)
      echo -e "Online Users:"
      for user in $online_users; do
        echo -e "\e[32m$user\e[0m"
      done
      ;;
    offline)
      echo -e "Offline Users:"
        for user in $all_users; do
          if ! [[ $online_users =~ $user ]]; then
            echo -e "\e[31m$user\e[0m"
          fi
        done
        ;;
    *)
      echo -e "All Users:"
      for user in $all_users; do
        if [[ $online_users =~ $user ]]; then
          echo -e "$user \e[32m(online)\e[0m"
        else
          echo -e "$user \e[31m(offline)\e[0m"
        fi
      done
      ;;
  esac
}

getinfo() {
  if [ -z "$1" ]; then
    echo "Usage: getinfo username"
    return 1
  fi

  local username="$1"

  local uptime=$(last -F -n 1 "$username" | head -n 1 | awk '{print $6, $7, $8, $9, $10}')
  uptime=${uptime:-"No recent sessions"}

  echo -e "Information for user: \e[33m$username\e[0m"
  echo -e "Uptime: \e[32m$uptime\e[0m"

  echo -e "Processes running:"
  ps -u "$username" -o pid=,cmd= | awk '{printf "  %-8s %s\n", $1, $0}' | cut -d' ' -f1,3-
}

extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <path/filename>"
    return 1
  fi
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.Z)         uncompress "$1";;
      *.7z)        7z x "$1"      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}

backup() {
  if [ -z "$1" ]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.bak"
}

server_info() {
  local online_users=$(who | cut -d' ' -f1 | sort | uniq)
  local online_user_count=$(echo "$online_users" | wc -l)
  local current_user=$(whoami)

  echo -e "Welcome to RIT Servers!"
  echo -e "Current time is: $(date)"

  if [ "$online_user_count" -eq 1 ] && [[ $online_users == *"$current_user"* ]]; then
    echo -e "There is 1 user\e[32m online\e[0m - You!"
  else
    echo -e "There are $online_user_count user(s)\e[32m online\e[0m!"
  fi
}

checkport() {
  nc -zv "$1" "$2" && echo "Port $2 on $1 is open" || echo "Port $2 on $1 is closed"
}

netinfo() {
  ip addr show
}

clean_clear() {
  clear
  fastfetch
  server_info
}

leave() {
  killall sshd
}

get_tools
update_dotfiles
clean_clear
