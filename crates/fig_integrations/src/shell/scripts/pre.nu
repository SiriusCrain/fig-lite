mkdir ~/.local/bin | ignore

def pathadd [path: string] {
  if not ($env.PATH | any {|it| $it == $path }) {
    $env.PATH | prepend $path
  } else {
    $env.PATH
  }
}

let-env PATH = pathadd $"($env.HOME)/.local/bin"
let-env PATH = pathadd $"($env.HOME)/.local/bin"

if "BAY_NEW_SESSION" in $env {
  let-env BAYTERM_SESSION_ID = $nothing
  let-env BAY_TERM = $nothing
  let-env BAY_NEW_SESSION = $nothing
}

if "BAY_SET_PARENT_CHECK" not-in $env {
  if "BAY_PARENT" not-in $env and "BAY_SET_PARENT" in $env {
    let-env BAY_PARENT = $env.BAY_SET_PARENT
    let-env BAY_SET_PARENT = $nothing
  }
  let-env BAY_SET_PARENT_CHECK = 1
}


let result = (^{{CLI_BINARY_NAME}} _ should-figterm-launch | complete)
let-env SHOULD_BAYTERM_LAUNCH = $result.exit_code

let should_launch = (
    ("PROCESS_LAUNCHED_BY_BAY" not-in $env or ($env.PROCESS_LAUNCHED_BY_BAY | str length) == 0)
    and ($env.SHOULD_BAYTERM_LAUNCH == 0 or
       ($env.SHOULD_BAYTERM_LAUNCH == 2 and "BAY_TERM" not-in $env))
)

if $should_launch {
  let BAY_SHELL = ({{CLI_BINARY_NAME}} _ get-shell | complete).stdout

  let fig_term_name = "nu (figterm)"
  let figterm_path = if ([$env.HOME ".fig" "bin" $fig_term_name] | path join | path exists) {
    [$env.HOME ".fig" "bin" $fig_term_name] | path join
  } else if (which figterm | length) > 0 {
    which figterm | first | get path
  } else {
    [$env.HOME ".fig" "bin" "figterm"] | path join
  }

  with-env {
    BAY_SHELL: $BAY_SHELL
  } {
    exec $figterm_path
  }
}
