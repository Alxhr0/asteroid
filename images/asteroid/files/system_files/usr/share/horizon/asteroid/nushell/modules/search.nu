def search [program: string] {
  let info = (which $program)

  if ($info | is-empty) {
    error make {
      msg: $"Program not found: ($program)"
    }
  } else {
    $info.0.path
  }
}
