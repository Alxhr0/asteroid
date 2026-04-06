$env.config.show_banner = false
$env.config.table.mode = 'none'

#source /etc/asteroid/nushell_modules/starship.nu
source /usr/share/asteroid/nushell/modules/zoxide.nu
source /usr/share/asteroid/nushell/modules/search.nu

def custom_prompt [] {
    let user = (whoami)
    let host = (hostname)
    let path = (if $env.PWD == $nu.home-path { "~" } else if $env.PWD == $"/home/($user)" { "~" } else if $env.PWD == $"/var/home/($user)" { "~" } else if $env.PWD == "/" { "/" }  else { $env.PWD | path basename })


    # Colors (ANSI escape codes for 24-bit color)
    let magenta = "\e[35m"
    let grey = "\e[38;2;128;128;128m"
    let cyan = "\e[38;5;81m"
    let reset = "\e[0m"
    let blue = "\e[94m"
    let green = "\e[32m"
    let darkgrey = "\e[90m"
    let white = "\e[97m"

    # Build prompt
    $"($green)($user)($reset)@($green)($host)($reset) [ ($white)($path)($reset) ] $ "
}

$env.PROMPT_COMMAND = { custom_prompt }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_COMMAND_RIGHT = ""

# Hooks
$env.config = {
  hooks: {
    pre_prompt: [{ ||
      if (which direnv | is-empty) {
        return
      }

      direnv export json | from json | default {} | load-env
      if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
        $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
      }
    }]
  }
}

# Goofy messages :P
$env.config.hooks.command_not_found = { |cmd|
  let insults = [
    "That's really cute, but no."
    "You really are an idiot."
    "Really?"
    "Wtf are you doing?"
    "Yep we're doomed"
    "rm you"
    "Why do you persist?"
    "COME NOW TAKE THE STEP DON'T TRY AGAIN"
    "null"
    "You've tried..."
    "killall -9 init"
    "Why bother?"
    "*sigh*"
    "Good news: you’re creative. Bad news: computers don’t care."
    "Oh, honey, no."
    "Somewhere, a real command is crying."
    "killall -9 system"
    "omfg"
    "NOOOOO"
    "Fuck off"
    "Die."
    "How pathetic!"
    "Failure."
    "Wow just wow!"
    "Howdy I'm the real command and you're an idiot!"
    "Take a break and never come back"
    "Lovely."
    "That's no bueno, you know?"
    "Error error error error- You get it?"
    "..."
    "Disappointing"
  ]

  let choice = (random int 0..(($insults | length) - 1))
  $insults | get $choice
}

# Aliases and functions
alias cd = z
alias ls = eza --icons
alias gadd = git add . -v
alias gstatus = git status .
alias gclone = git clone
alias commit = git commit -m
alias gpush = git push
alias clr = clear
alias gstash = git stash
alias cat = bat -p --theme=ansi
alias dbox = distrobox

def hfetch [] {
  clear ; hyfetch
}

def fetch [
  --logo(-l): string
  --config(-c): string
] {
  mut args = []

  if $config != null {
    $args = $args ++ ['-c' $config]
  }

  if $logo != null {
    $args = $args ++ ['-l' $logo]
  }

  clear
  fastfetch ...$args
  echo ""
}
