# clutch.zsh — Claude utility wrapper
# Intercepts `claude --resume .` to resolve `.` to the most recent session for $PWD

clutch::resolve_recent_session() {
  python3 -c "
import json, glob, os

cwd = os.getcwd()
sessions = []

# Check active sessions in sessions/*.json
for f in glob.glob(os.path.expanduser('~/.claude/sessions/*.json')):
    try:
        with open(f) as fh:
            d = json.load(fh)
        if d.get('cwd') == cwd:
            sessions.append((d.get('startedAt', 0), d.get('sessionId', '')))
    except Exception:
        pass

# Check project-based sessions in projects/<encoded-cwd>/*.jsonl
proj_name = cwd.replace('/', '-')
proj_dir = os.path.expanduser(f'~/.claude/projects/{proj_name}')
if os.path.isdir(proj_dir):
    for f in glob.glob(os.path.join(proj_dir, '*.jsonl')):
        try:
            mtime = os.path.getmtime(f)
            sid = os.path.splitext(os.path.basename(f))[0]
            sessions.append((mtime * 1000, sid))
        except Exception:
            pass

# Deduplicate by session ID, keeping highest timestamp
by_id = {}
for ts, sid in sessions:
    if sid not in by_id or ts > by_id[sid]:
        by_id[sid] = ts
sessions = sorted(by_id.items(), key=lambda x: -x[1])

if sessions:
    print(sessions[0][0])
" 2>/dev/null
}

claude() {
  local args=("$@")
  local i
  for (( i=0; i < ${#args[@]}; i++ )); do
    if [[ "${args[$i]}" == "--resume" || "${args[$i]}" == "-r" ]]; then
      local next=$(( i + 1 ))
      if [[ "${args[$next]}" == "." ]]; then
        local session_id
        session_id=$(clutch::resolve_recent_session)
        if [[ -z "$session_id" ]]; then
          echo "clutch: no session found for $(pwd)" >&2
          return 1
        fi
        args[$next]="$session_id"
      fi
      break
    fi
  done
  command claude "${args[@]}"
}
