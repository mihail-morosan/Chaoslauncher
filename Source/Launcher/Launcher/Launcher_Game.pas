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
uses windows,sysutils,registry,Plugins,versions,Util,inifiles;

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
    ini:TInifile;
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

  ini:=TInifile.create('Settings.ini');

  FGamePath:=ini.ReadString('Launcher','GamePath','C:\Starcraft\');

  ini.free;

  //AssignFile(tfIn, C_FNAME);
  //
  //try
  //  reset(tfIn);
  //  readln(tfIn, s);
  //  CloseFile(tfIn);
  //
  //except
  //  on E: EInOutError do
  //   writeln('File handling error occurred. Details: ', E.Message);
  //end;

  //FGamePath:=s;
end;

procedure SetGamePath(NewPath:String);
var reg:TRegistry;
begin
  FGamePath:=NewPath;
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
