unit Launcher_Game;

{$MODE Delphi}

interface

uses FileUtil;

const GameName='Starcraft';
      GameShortName='SC';
function GamePath:String;
procedure LoadGameInfo;
procedure SetGamePath(NewPath:String);
function GameFindProcessID:Cardinal;
procedure GameListVersions;

implementation
uses windows,sysutils,registry,Plugins,versions,Util;

var FGamePath:String;

function GamePath:String;
begin
  result:=FGamePath
end;

procedure UpdateGamePath;
//var reg:TRegistry;
const
      C_FNAME = 'settings.txt';
var tfIn: TextFile;
    s: string;
begin
  //reg:=nil;
  //try
  //  reg:=TRegistry.create;
  //  reg.RootKey:=HKEY_CURRENT_USER;
  //  reg.OpenKeyReadOnly('SOFTWARE\Blizzard Entertainment\Starcraft');
  //  FGamePath:=reg.ReadString('InstallPath');
  //  if FGamePath = ''
  //    then begin
  //      reg.RootKey:=HKEY_LOCAL_MACHINE;
  //      reg.OpenKeyReadOnly('SOFTWARE\Blizzard Entertainment\Starcraft');
  //      FGamePath:=reg.ReadString('InstallPath');
  //    end;
  // FGamePath:=FGamePath+'\';
  //finally
  //  reg.free;
  //end;


  AssignFile(tfIn, C_FNAME);

  // Embed the file handling in a try/except block to handle errors gracefully
  try
    // Open the file for reading
    reset(tfIn);

    // Keep reading lines until the end of the file is reached
    //while not eof(tfIn) do
    //begin
      readln(tfIn, s);
    //  writeln(s);
    //end;

    // Done so close the file
    CloseFile(tfIn);

  except
    on E: EInOutError do
     writeln('File handling error occurred. Details: ', E.Message);
  end;

  //FGamePath:='E:\Games\Starcraft\';
  FGamePath:=s;
end;

procedure SetGamePath(NewPath:String);
var reg:TRegistry;
begin
  reg:=nil;
  try
    if(NewPath<>'')and
      (NewPath[length(NewPath)]<>'\')
      then NewPath:=NewPath+'\';
    reg:=TRegistry.create;
    reg.RootKey:=HKEY_LOCAL_MACHINE;
    reg.OpenKey('SOFTWARE\Blizzard Entertainment\Starcraft',true);
    reg.WriteString('InstallPath',copy(NewPath,1,length(NewPath)-1));//Remove trailing \
    reg.WriteString('Program',NewPath+'Starcraft.exe');
    FGamePath:=NewPath;
  finally
    reg.free;
  end;
end;

procedure LoadGameInfo;
begin
  UpdateGamePath;
end;

function GameFindProcessID:Cardinal;
var wnd:hwnd;
begin
  wnd:=FindWindow('SWarClass',nil);
  if wnd=0 then result:=0;
  GetWindowThreadProcessId(Wnd, @result);
end;

procedure GameListVersions;
var error:integer;
    SRec:TSearchRec;
    GameVersion:TGameVersion;
begin
  error:=FindFirstUTF8(GamePath+'Starcraft*.exe',faAnyFile and not faDirectory,SRec); { *Converted from FindFirst* }
  while error=0 do
   begin
    GameVersion.Filename:=GamePath+SRec.Name;
    GameVersion.Version:=stringreplace(GetLocalizedVersionValue(GameVersion.Filename,'ProductVersion'),'Version ','',[]);
    Str_FitZeroTerminated( GameVersion.Version);
    GameVersion.Name:='Starcraft '+GameVersion.Version;
    GameVersion.Ladder:=nil;
    AddGameVersion(GameVersion);
    error:=FindNextUTF8(SRec); { *Converted from FindNext* }
   end;
  if (Error<>ERROR_NO_MORE_FILES)and(Error<>ERROR_FILE_NOT_FOUND)and(Error<>ERROR_PATH_NOT_FOUND)
    then MessageBox(0,PChar('Search for Game executables failed '+GetErrorString(Error)), 'Error', MB_OK + MB_ICONSTOP);
end;


begin
  LoadGameInfo;
end.
