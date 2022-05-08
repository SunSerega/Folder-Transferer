
1. Start `Server.exe` on the pc with files to transfer.

The server creates the `Bucket` folder, which is the folder to be copied to the target pc.

---

### On the same local network (connected to the same router)

2. Start `Client.exe` and enter the IP that `Server.exe` has shown.

---

### Otherwise

You will need port 11000 forwarded on pc running `Server.exe`.
`Server.exe` shows which IP to port forward. After that:

2. Start `ClientRemote.exe` and enter the public IP (which needs to be static) of pc running `Server.exe`.
