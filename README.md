# easy-tmux
## tmux made easy

### Persistent Terminal Manager (Bash + tmux)

This utility allows you to manage up to 9 persistent terminal sessions on your server.  
Even if you disconnect your SSH session, the terminals continue running in the background.  

### Features

- Open or create terminals numbered 1-9
- Kill a single terminal or **all** your tmux sessions
- Rename the labels of terminals (display only, does not change session names)
- Displays the status of each terminal:
  - `Inactive` → session does not exist
  - `Idle` → shell ready, no process running
  - `Running` → a process is running in that terminal
- Labels persist between script launches by using a .terms_labels file in the user home directory

### Usage

```bash
chmod +x easy-tmux.sh
./easy-tmux.sh
```

### Menu shortcuts:
1-9 → open or attach to terminal
k → stop a terminal, or type all to kill all sessions
r → rename the display label of a terminal
q → quit the script (sessions are still active and terminal can be reopen by launching the script again)

### Note on tmux usage
When inside a tmux session, the default prefix is Ctrl+b.
To detach from the session without closing it, press:
Ctrl+b then d


