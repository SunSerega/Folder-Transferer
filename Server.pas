uses System.Net;
uses System.Net.Sockets;

uses NetData;

procedure SendFolder(path: string; conn: SockConnection; bw: System.IO.BinaryWriter);
begin
  writeln($'Sending {path}');
  
  bw.Write(path);
  
  var f := System.IO.Directory.GetFiles(path);
  bw.Write(f.Length);
  foreach var fname in f do
  begin
    writeln($'Sending {fname}');
    bw.Write(fname);
    var str := System.IO.File.OpenRead(fname);
    bw.Write(str.Length);
    var br := new System.IO.BinaryReader(str);
    while str.Position<str.Length do
    begin
      bw.Write(br.ReadBytes(1024*1024*100));
      conn.FlushData;
    end;
    
    str.Flush;
    str.Close;
  end;
  
  f := System.IO.Directory.GetDirectories(path);
  bw.Write(f.Length);
  foreach var npath in f do SendFolder(npath, conn, bw);
  
end;

begin
  try
    System.IO.Directory.CreateDirectory('Bucket');
    
    var ipHostInfo := Dns.Resolve(Dns.GetHostName());
    var ipAddress := ipHostInfo.AddressList[0];
    var localEndPoint := new IPEndPoint(ipAddress, 11000);
    
    var listener := new Socket(
      AddressFamily.InterNetwork,
      SocketType.Stream,
      ProtocolType.Tcp
    );
    
    listener.Bind(localEndPoint);
    listener.Listen(1);
    
    Writeln($'waiting at {ipAddress}');
    var handler := listener.Accept;
    writeln($'Connected to {handler.RemoteEndPoint}');
    
    var conn := new SockConnection(handler);
    SendFolder('Bucket', conn, conn.CreateWriter);
    conn.FlushData;
    
    handler.Shutdown(SocketShutdown.Both);
    handler.Close;
    
  except
    on e: Exception do Writeln(e);
  end;
  writeln('done');
  readln;
end.