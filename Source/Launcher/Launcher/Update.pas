unit Update;

{$MODE Delphi}

interface
uses sysutils,Util, FileUtil;
type EUpdateFailed=class(Exception);
     EUpdateInvalidTempPath=class(EUpdateFailed);

type
TUpdateFlag=(ufCompressed,ufIncremental);
TUpdateFlags=set of TUpdateflag;

TUpdater=class;

TUpdateModule=class
  private
    FUpdater: TUpdater;
  protected
  public
    procedure CheckForUpdates(var desc:String);virtual;abstract;
    property Updater:TUpdater read FUpdater;
    constructor Create(AUpdater:TUpdater);
end;

TUpdateFile=record
    Url:String;
    TempName:String;
    RealName:String;
    md5:String;
    Flags:TUpdateFlags;
  end;


TUpdater=class
  private
    GetModuleCount: integer;
    FFiles:array of TUpdateFile;
    FModules:array of TUpdateModule;
    FTempPath: String;
    function GetModule(Index:integer):TUpdateModule;
    procedure SetTempPath(const Value: String);
    function GetFileCount: integer;
    procedure AddModule(Module:TUpdateModule);
  protected
  public
    property Modules[Index:integer]:TUpdateModule read GetModule;
    property ModuleCount:integer read GetModuleCount;
    property TempPath:String read FTempPath write SetTempPath;
    property FileCount:integer read GetFileCount;
    function CheckForUpdates(out desc:String):boolean;
    function InstallUpdates:boolean;
    procedure AddFile(ARealName,AUrl:String;Flags:TUpdateFlags=[]);
    destructor Destroy;override;
end;


var Updater:TUpdater;
    UpdatesReady:boolean=false;
    RestartLauncher:boolean=false;
implementation
uses windows,classes,shellapi,logger,zlib;


{ TUpdater }

procedure TUpdater.AddFile(ARealName,AUrl:String;Flags:TUpdateFlags);
begin
  SetLength(FFiles,length(FFiles)+1);
  FFiles[high(FFiles)].Url:=AUrl;
  FFiles[high(FFiles)].RealName:=ARealName;
  FFiles[high(FFiles)].TempName:='Temp'+inttostr(high(FFiles))+'.upd';
  FFiles[high(FFiles)].Flags:=Flags;
end;

procedure TUpdater.AddModule(Module: TUpdateModule);
begin
  SetLength(FModules,length(FModules)+1);
  FModules[high(FModules)]:=Module;
end;

function TUpdater.CheckForUpdates(out desc:String): boolean;
var i:integer;
begin
  desc:='';
  setlength(FFiles,0);
  for I := 0 to length(FModules)-1 do
    FModules[i].CheckForUpdates(desc);
  result:=length(FFiles)>0;
end;

destructor TUpdater.Destroy;
var i:integer;
begin
  for i := 0 to length(FModules)-1 do
    FModules[i].free;
  inherited;
end;



function TUpdater.GetFileCount: integer;
begin
  result:=length(FFiles);
end;

function TUpdater.GetModule(Index: integer): TUpdateModule;
begin
  if (Index<0)or(Index>high(FModules))
    then raise ERangeError.create('Invalid Index '+inttostr(Index));
  result:=FModules[Index];
end;

function TUpdater.InstallUpdates:boolean;
begin
  result:=false;
  if FileExistsUTF8(TempPath+'UpdateInfo.dat') { *Converted from FileExists* }
    then begin
      result:=true;
      ShellExecute(0,'open',PChar(extractfilepath(paramstr(0))+'ChaosUpdater.exe'),PChar('/install "'+paramstr(0)+'" "'+TempPath+'"'),'',sw_normal);
    end;
end;

procedure TUpdater.SetTempPath(const Value: String);
begin
  FTempPath := Value;
end;

{ TUpdateModule }

constructor TUpdateModule.Create(AUpdater: TUpdater);
begin
  inherited Create;
  Assert(AUpdater<>nil,'TUpdateModule.Create called with Updater=nil');
  FUpdater:=AUpdater;
  AUpdater.AddModule(self);
end;

initialization
  Updater:=TUpdater.create;
  Updater.TempPath:=extractfilepath(paramstr(0))+'Temp\';
finalization
  Updater.free;
end.
