# clutch

CLaude Utility / Tab Completion Helpers

## Install

```bash
./install.sh
```

Then restart your shell (or `source ~/.zshrc`).

## Features

### Tab completion for `--resume`

```bash
claude --resume <TAB>        # shows recent named sessions
claude --resume collab<TAB>  # filters to sessions matching "collab"
```

### Resume most recent session in current directory

```bash
claude --resume .
```

Resolves `.` to the most recent session that was started in `$PWD`.
