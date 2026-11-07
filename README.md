# Monopoly
A simple Monopoly game. You can play with human or computer players

Keep the `boards` folder next to the executable. The game locates board files
relative to the executable, so you can launch it from any working directory as
long as that folder is present.

The Windows x64 portable build is distributed separately as a native
executable with the OCaml runtime and Visual C++ runtime DLL included. It is
for 64-bit Windows 10 and later; it does not run on Linux, WSL, or macOS.
Extract the package and run `Monopoly.exe` from a terminal, keeping the
included `boards` folder beside it.

During a game, press `4` to view the board as a rectangular map. Spaces follow
the order defined by the selected board file, so custom boards are displayed
around the same perimeter layout as the classic board.
