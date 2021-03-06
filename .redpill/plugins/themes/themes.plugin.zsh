
theme()
{
  if [ -z "$1" ] || [ "$1" = "random" ]; then
    local themes=($ZSH/themes/*zsh-theme)
	  N=${#themes[@]}
	  ((N=(RANDOM%N)+1))
	  RANDOM_THEME=${themes[$N]}
	  source "$RANDOM_THEME"
	  echo "[red-pill] Random theme '$RANDOM_THEME' loaded..."
  else
	  if [ -f "$ZSH_CUSTOM/$1.zsh-theme" ]; then
	    source "$ZSH_CUSTOM/$1.zsh-theme"
	  else
	    source "$ZSH/themes/$1.zsh-theme"
	  fi
  fi

  unset M
  unset RANDOM
  unset RANDOM_THEME
}

lstheme()
{
  cd $ZSH/themes
  ls *zsh-theme | sed 's,\.zsh-theme$,,'
}
