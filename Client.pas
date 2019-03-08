uses System.Net;
uses System.Net.Sockets;

uses NetData;

const
  file_copy_buff_size = 1024*1024;

procedure ReceiveFolder(br: System.IO.BinaryReader);
begin
  
  var path := br.ReadString;
  writeln($'Receiving {path}');
  System.IO.Directory.CreateDirectory(path);
  
  loop br.ReadInt32 do
  begin
    var f := System.IO.File.Create(br.ReadString);
    var bw := new System.IO.BinaryWriter(f);
    var l := br.ReadInt64;
    
    while l>0 do
    begin
      var cl := Min(l, file_copy_buff_size);
      bw.Write(br.ReadBytes(cl));
      l -= cl;
      f.Flush;
    end;
    
    f.Close;
  end;
  
  loop br.ReadInt32 do ReceiveFolder(br);
  
end;

begin
  try
    var ipHostInfo := Dns.Resolve(Dns.GetHostName());
    var ipAddress := ipHostInfo.AddressList[0];
    var ip_bts := ipAddress.GetAddressBytes;
    
    write($'Connect to: {ip_bts[0]}.{ip_bts[1]}.{ip_bts[2]}.');
    
    ip_bts[3] := ReadlnInteger;
    ipAddress := new System.Net.IPAddress(ip_bts);
    var remoteEP := new IPEndPoint(ipAddress, 11000);
    
    var sender := new Socket(
    AddressFamily.InterNetwork,
    SocketType.Stream,
    ProtocolType.Tcp);
    
    sender.Connect(remoteEP);
    
    ReceiveFolder(SockConnection.Create(sender).CreateReader);
    
    sender.Shutdown(SocketShutdown.Both);
    sender.Close;
  except
    on e: Exception do Writeln(e);
  end;
  writeln('done');
  readln;
end.