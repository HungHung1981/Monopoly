let path fname =
  Filename.concat
    (Filename.concat (Filename.dirname Sys.executable_name) "boards")
    fname
