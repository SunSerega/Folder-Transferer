
1. Start `Server.exe` on computer that has needed files.

This creates `Bucket` folder, which is the folder to be copied to target pc.

---

### On the same local network (connected to the same router)

2. Start `Client.exe` and enter ip, that `Server.exe` has shown.

---

### Otherwise

You will need to have port 11000 forwarded on pc running `Server.exe`.
`Server.exe` shows which ip to port-forward. After that:

2. Start `ClientRemote.exe` and enter public ip (which needs to be static) of pc running `Server.exe`.
