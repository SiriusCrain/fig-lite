def pathadd [path: string] {
  if not ($env.PATH | any {|it| $it == $path }) {
    $env.PATH | prepend $path
  } else {
    $env.PATH
  }
}

let-env PATH = pathadd $"($env.HOME)/.local/bin"
let-env BAY_SHELL = (^{{CLI_BINARY_NAME}} _ get-shell)

let-env PATH = $env.PATH

def-env fig_osc [s: string] {
  $"(ansi -o '697');($s)(char bel)"
}

def-env print_fig_osc [s: string] {
  print -n $"(fig_osc $s)"
}

def-env fig_reset_hooks [] {
  let pre_prompt_hook = ($env.config.hooks.pre_prompt | append {(fig_pre_prompt_hook)})
  let pre_execution_hook = ($env.config.hooks.pre_execution | append {(fig_pre_execution_hook)})

  let hooks = (
    $env.config.hooks
    | upsert pre_prompt $pre_prompt_hook
    | upsert pre_execution $pre_execution_hook
  )

  let-env config = ($env.config | upsert hooks $hooks)
}

def-env fig_pre_execution_hook [] {
  if "BAYTERM_SESSION_ID" in $env {
    print_fig_osc $"OSCLock=($env.BAYTERM_SESSION_ID)"
  }
  print_fig_osc "PreExec"

  # let-env PROMPT_COMMAND = if "PROMPT_COMMAND" in $env {
  #   if "BAY_USER_PROMPT_COMMAND" in $env {
  #       $env.BAY_USER_PROMPT_COMMAND
  #   } else {
  #       $env.PROMPT_COMMAND
  #   }
  # } else { $nothing }

  # if "PROMPT_COMMAND" in $env and "BAY_USER_PROMPT_COMMAND" in $env {
  #   let-env PROMPT_COMMAND = $env.BAY_USER_PROMPT_COMMAND
  # }

  # let-env PROMPT_COMMAND_RIGHT = if "PROMPT_COMMAND_RIGHT" in $env {
  #   if "BAY_USER_PROMPT_COMMAND_RIGHT" in $env {
  #       $env.BAY_USER_PROMPT_COMMAND_RIGHT
  #   } else {
  #       $env.PROMPT_COMMAND_RIGHT
  #   }
  # } else { $nothing }

  # if "PROMPT_COMMAND_RIGHT" in $env and "BAY_USER_PROMPT_COMMAND_RIGHT" in $env {
  #   let-env PROMPT_COMMAND_RIGHT = $env.BAY_USER_PROMPT_COMMAND_RIGHT
  # }

  # let-env PROMPT_INDICATOR = if "PROMPT_INDICATOR" in $env {
  #   if "BAY_USER_PROMPT_INDICATOR" in $env {
  #       $env.BAY_USER_PROMPT_INDICATOR
  #   } else {
  #       $env.PROMPT_INDICATOR
  #   }
  # } else { $nothing }

  # if "PROMPT_INDICATOR" in $env and "BAY_USER_PROMPT_INDICATOR" in $env {
  #   let-env PROMPT_INDICATOR = $env.BAY_USER_PROMPT_INDICATOR
  # }

  # let-env PROMPT_INDICATOR_VI_INSERT = if "PROMPT_INDICATOR_VI_INSERT" in $env {
  #   if "BAY_USER_PROMPT_INDICATOR_VI_INSERT" in $env {
  #       $env.BAY_USER_PROMPT_INDICATOR_VI_INSERT
  #   } else {
  #       $env.PROMPT_INDICATOR_VI_INSERT
  #   }
  # } else { $nothing }

  # if "PROMPT_INDICATOR_VI_INSERT" in $env and "BAY_USER_PROMPT_INDICATOR_VI_INSERT" in $env {
  #   let-env PROMPT_INDICATOR_VI_INSERT = $env.BAY_USER_PROMPT_INDICATOR_VI_INSERT
  # }

  # let-env PROMPT_INDICATOR_VI_NORMAL = if "PROMPT_INDICATOR_VI_NORMAL" in $env {
  #   if "BAY_USER_PROMPT_INDICATOR_VI_NORMAL" in $env {
  #       $env.BAY_USER_PROMPT_INDICATOR_VI_NORMAL
  #   } else {
  #       $env.PROMPT_INDICATOR_VI_NORMAL
  #   }
  # } else { $nothing }

  # if "PROMPT_INDICATOR_VI_NORMAL" in $env and "BAY_USER_PROMPT_INDICATOR_VI_NORMAL" in $env {
  #   let-env PROMPT_INDICATOR_VI_NORMAL = $env.BAY_USER_PROMPT_INDICATOR_VI_NORMAL
  # }

  # let-env PROMPT_MULTILINE_INDICATOR = if "PROMPT_MULTILINE_INDICATOR" in $env {
  #   if "BAY_USER_PROMPT_MULTILINE_INDICATOR" in $env {
  #       $env.BAY_USER_PROMPT_MULTILINE_INDICATOR
  #   } else {
  #       $env.PROMPT_MULTILINE_INDICATOR
  #   }
  # } else { $nothing }

  # if "PROMPT_MULTILINE_INDICATOR" in $env and "BAY_USER_PROMPT_MULTILINE_INDICATOR" in $env {
  #   let-env PROMPT_MULTILINE_INDICATOR = $env.BAY_USER_PROMPT_MULTILINE_INDICATOR
  # }
}

def-env fig_pre_prompt_hook [] {
    print_fig_osc $"OSCUnlock=($env.BAYTERM_SESSION_ID)"
    print_fig_osc $"Dir=($env.PWD)"
    print_fig_osc "Shell=nu"
    if "BAY_SHELL" in $env {
      print_fig_osc $"ShellPath=($env.BAY_SHELL)"
    }
    if "WSL_DISTRO_NAME" in $env {
      print_fig_osc $"WSLDistro=($env.WSL_DISTRO_NAME)"
    }
    print_fig_osc $"PID=($nu.pid)"
    if "LAST_EXIT_CODE" in $env {
      print_fig_osc $"ExitCode=($env.LAST_EXIT_CODE)"
    }
    print_fig_osc $"TTY=(^tty)"
    if "BAY_LOG_LEVEL" in $env {
      print_fig_osc $"Log=($env.BAY_LOG_LEVEL)"
    }

    print_fig_osc $"NuHintColor=($env.config.color_config.hints)"

    if "USER" in $env {
      print_fig_osc $"User=($env.USER)"
    } else {
      print_fig_osc "User=root"
    }

    # if $env.BAY_HAS_SET_PROMPT == 1 {
    #   fig_pre_execution_hook
    # }

    if (which fig | length) >= 1 {
      let result = ({{CLI_BINARY_NAME}} _ pre-cmd | complete)
      if $result.stdout == "EXEC_NEW_SHELL" {
        let-env BAY_DOTFILES_SOURCED = $nothing
        exec nu
      } else if $result.stdout == "" {
        # do nothing
      } else {
        print $"Unknown result from pre-cmd: ($result.stdout)"
      }
    }

    let-env BAY_HAS_SET_PROMPT = 1
}

def-env fig_set_prompt [] {
  if "PROMPT_COMMAND" in $env {
    let-env BAY_PROMPT_COMMAND = $env.PROMPT_COMMAND
    let-env PROMPT_COMMAND = {
      $"(fig_osc 'StartPrompt')(do $env.BAY_PROMPT_COMMAND)"
    }
  }

  if "PROMPT_COMMAND_RIGHT" in $env {
    let-env BAY_PROMPT_COMMAND_RIGHT = $env.PROMPT_COMMAND_RIGHT
    let-env PROMPT_COMMAND_RIGHT = {
      $"(fig_osc 'StartPrompt')(do $env.BAY_PROMPT_COMMAND_RIGHT)(fig_osc 'EndPrompt')"
    }
  }

  if "PROMPT_INDICATOR" in $env {
    let-env BAY_PROMPT_INDICATOR = $env.PROMPT_INDICATOR
    let-env PROMPT_INDICATOR = {
      $"(do $env.BAY_PROMPT_INDICATOR)(fig_osc 'EndPrompt')(fig_osc $"NewCmd=($env.BAYTERM_SESSION_ID)")"
    }
  }

  if "PROMPT_INDICATOR_VI_INSERT" in $env {
    let-env BAY_PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR_VI_INSERT
    let-env PROMPT_INDICATOR_VI_INSERT = {
      $"(do $env.BAY_PROMPT_INDICATOR_VI_INSERT)(fig_osc 'EndPrompt')(fig_osc $"NewCmd=($env.BAYTERM_SESSION_ID)")"
    }
  }

  if "PROMPT_INDICATOR_VI_NORMAL" in $env {
    let-env BAY_PROMPT_INDICATOR_VI_NORMAL = $env.PROMPT_INDICATOR_VI_NORMAL
    let-env PROMPT_INDICATOR_VI_NORMAL = {
      $"(do $env.BAY_PROMPT_INDICATOR_VI_NORMAL)(fig_osc 'EndPrompt')(fig_osc $"NewCmd=($env.BAYTERM_SESSION_ID)")"
    }
  }

  if "PROMPT_MULTILINE_INDICATOR" in $env {
    let-env BAY_PROMPT_MULTILINE_INDICATOR = $env.PROMPT_MULTILINE_INDICATOR
    let-env PROMPT_MULTILINE_INDICATOR = {
      $"(fig_osc 'StartPrompt')(do $env.BAY_PROMPT_MULTILINE_INDICATOR)(fig_osc 'EndPrompt')"
    }
  }
}

fig_set_prompt
fig_reset_hooks

if "PROCESS_LAUNCHED_BY_BAY" in $env {
  print_fig_osc "DoneSourcing"
}

(^{{CLI_BINARY_NAME}} _ pre-cmd | complete | ignore)
