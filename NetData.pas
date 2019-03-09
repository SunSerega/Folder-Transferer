unit NetData;

interface

uses System.Net;
uses System.Net.Sockets;

type
  SockConnection = sealed class
    
    private sock: Socket;
    private otp_str := new System.IO.MemoryStream;
    
    
    public property CanRead: boolean read sock.Available<>0;
    
    public property CurrSock: Socket read sock;
    
    
    private constructor := exit;
  
  public constructor(sock: Socket);
  
  
  public function CreateReader: System.IO.BinaryReader;
  
  public function CreateWriter: System.IO.BinaryWriter;
  
  
  public procedure FlushData;
  
  public procedure WaitForData;
  
  public procedure WaitForData(t: System.TimeSpan);
  
  public procedure Shutdown;

end;

implementation

{$region Misc}

function ToIPEndPoint(self: string): System.Net.IPEndPoint; extensionmethod;
begin
  var ss := self.Split(new char[](':'), 2);
  var Address := new IPAddress(ss[0].Split(new char[]('.'), 4).ConvertAll(s -> byte.Parse(s)));
  Result := new IPEndPoint(Address, ss[1].ToInteger);
end;

{$endregion Misc}

type
  NetReceiveStream = class(System.IO.Stream)
    
    public property CanRead: boolean read boolean(true); override;
    
    public property CanSeek: boolean read boolean(false); override;
    
    public property CanTimeout: boolean read boolean(false); override;
    
    public property CanWrite: boolean read boolean(false); override;
    
    public property Length: int64 read int64.MaxValue; override;
    
    public property Position: int64 read 0 write raise new System.NotSupportedException; override;
    
    public function Seek(offset: int64; origin: System.IO.SeekOrigin): int64; override;
    begin
      Result := 0;
      raise new System.NotSupportedException;
    end;
    
    public procedure SetLength(value: int64); override :=
    raise new System.NotSupportedException;
    
    public procedure Write(buffer: array of byte; offset: integer; count: integer); override :=
    raise new System.NotSupportedException;
    
    public procedure Flush; override :=
    raise new System.NotSupportedException;
    
    private constructor :=
    raise new System.NotSupportedException;
    
    
    
    private sock: Socket;
    
    public constructor(sock: Socket) :=
    self.sock := sock;
    
    public function Read(buffer: array of byte; offset: integer; count: integer): integer; override;
    begin
      while sock.Available=0 do Sleep(10);
      Result := sock.Receive(buffer, offset, count, SocketFlags.None);
    end;
    
  end;

{$region SockConnection}

{$region constructor's}

constructor SockConnection.Create(sock: Socket);
begin
  self.sock := sock;
end;

{$endregion constructor's}

{$region CreateIO}

function SockConnection.CreateReader := new System.IO.BinaryReader(new NetReceiveStream(sock));

function SockConnection.CreateWriter := new System.IO.BinaryWriter(self.otp_str);

{$endregion CreateIO}

{$region IO}

procedure SockConnection.FlushData;
begin
  sock.Send(otp_str.ToArray);
  otp_str.SetLength(0);
end;

procedure SockConnection.WaitForData;
begin
  while sock.Available=0 do Sleep(10);
end;

procedure SockConnection.WaitForData(t: System.TimeSpan);
begin
  var ET := DateTime.UtcNow + t;
  while sock.Available = 0 do
    if DateTime.UtcNow < ET then
      Sleep(10) else
      raise new System.TimeoutException;
end;

procedure SockConnection.Shutdown;
begin
  sock.Shutdown(SocketShutdown.Both);
  sock.Close;
end;

{$endregion IO}

{$endregion SockConnection}

end.