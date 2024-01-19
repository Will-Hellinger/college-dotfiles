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

  # Getting user uptime
  local uptime=$(last -F -n 1 "$username" | head -n 1 | awk '{print $6, $7, $8, $9, $10}')
  uptime=${uptime:-"No recent sessions"}

  # Header
  echo -e "Information for user: \e[33m$username\e[0m"
  echo -e "Uptime: \e[32m$uptime\e[0m"

  # Processes
  echo -e "Processes running:"
  ps -u "$username" -o pid=,cmd= | awk '{printf "  %-8s %s\n", $1, $0}' | cut -d' ' -f1,3-
}

server_info(){
  echo -e "Welcome to RIT Servers!"
  echo -e "There are $online_user_count users\e[32m online\e[0m!"
}

clean_clear() {
  clear
  fastfetch
  server_info
}

user_count=$(wc -l /etc/passwd | cut -d' ' -f1)
online_user_count=$(who | cut -d' ' -f1 | sort | uniq | wc -l)

get_tools
update_dotfiles
clear
fastfetch
server_info
