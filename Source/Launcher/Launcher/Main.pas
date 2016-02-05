unit Main;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, CheckLst, ComCtrls, ImgList,
  registry, Buttons, FileUtil, math, shellapi, OneInstance, Update,
  Launcher_Game;

type
  TChaoslauncherForm = class(TForm)
    PageControl1: TPageControl;
    PluginTab: TTabSheet;
    Panel1: TPanel;
    Start: TButton;
    Versions: TComboBox;
    Pluginlist: TCheckListBox;
    Pluginname: TLabel;
    Plugindescription: TMemo;
    PluginVersion: TLabel;
    PluginStatusImgs12: TImageList;
    RunIfIncompatible: TCheckBox;
    PluginStatusImgs16: TImageList;
    PluginStatusImg: TImage;
    PluginStatus: TLabel;
    BanDangerImg: TImage;
    BanDanger: TLabel;
    PluginAuthor: TLabel;
    Config: TButton;
    ToolOpenDialog: TOpenDialog;
    SettingsTab: TTabSheet;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    ScInstallpath: TEdit;
    Label5: TLabel;
    StartMinimized: TCheckBox;
    MinimizeOnRun: TCheckBox;
    RunScOnStartup: TCheckBox;
    Label6: TLabel;
    InjectionMethod: TComboBox;
    SettingsOK: TButton;
    SettingsCancel: TButton;
    Autoupdate: TCheckBox;
    StartupTimer: TTimer;
    Diagnose: TButton;
    WarnNoAdmin: TCheckBox;
    Help: TButton;
    BrowseInstallPath: TButton;
    PathOpenDialog: TOpenDialog;
    ScPort: TComboBox;
    AllowMultiInstance: TCheckBox;
    ddemulate: TCheckBox;
    procedure StartClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ShowConfig(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VersionsChange(Sender: TObject);
    procedure PluginlistDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure PluginlistClick(Sender: TObject);
    procedure UpdatePluginlist(Sender: TObject);
    procedure RunIfIncompatibleClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ConfigClick(Sender: TObject);
    procedure PluginlistClickCheck(Sender: TObject);
    procedure StartLatestSC(Sender: TObject);
    procedure StartScVersion(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);

    procedure PageControl1Change(Sender: TObject);

    procedure RunTool(Sender: TObject);
    procedure SettingsChange(Sender: TObject);
    procedure LoadSettings(Sender: TObject);
    procedure SaveSettings(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ExceptionHandler(Sender: TObject; E: Exception);
    procedure About_WebsiteClick(Sender: TObject);
    procedure AppMinimize(Sender: TObject);
    procedure AppRestore(Sender: TObject);
    procedure GetScVersions(Sender: TObject);
    procedure RunTvAnts(Sender: TObject);
    procedure GetTvAnts1Click(Sender: TObject);
    procedure StartupTimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DiagnoseClick(Sender: TObject);
    procedure Attach1Click(Sender: TObject);
    procedure News_ChaosClick(Sender: TObject);
    procedure News_GGNetClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure News_TLClick(Sender: TObject);
    procedure BrowseInstallPathClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure WMShowInstance(var Message); message WM_ShowInstance;
    procedure SetRunIfIncompatible(Value:boolean);
  public
    { Public-Deklarationen }
  end;

var
  ChaoslauncherForm: TChaoslauncherForm;

implementation

uses Util, logger, Plugins, Tools, TvAnts, Plugins_BWL, Config,versions;

{$R *.lfm}
const LauncherUpdateUrl='http://winner.cspsx.de/Starcraft/Tool/Launcherupdate/';
var CurrentVersion:integer=-1;
    ToolsChanged:boolean=false;
    SettingsChanged:boolean=false;
    CurrentToolIndex:integer=-1;

//######## Helper ########

function GetCompatiblityIcon(Compatibility:TCompatibility):integer;
begin
  case Compatibility of
    coUnknown:            result:=3;
    coForbidden:          result:=2;
    coIncompatible:       result:=2;
    coPartiallyCompatible:result:=1;
    coCompatible:         result:=0;
    coRequired:           result:=0;
    else                  result:=3;
  end;
end;

function GetBanRiskIcon(BanRisk:TBanRisk):integer;
begin
  case BanRisk of
    brUnknown:result:=3;
    brNone:result:=0;
    brLow:result:=0;
    brMedium:result:=1;
    brHigh:result:=2;
    else result:=3;//Error
  end;
end;

procedure CheckGameVersions;
begin
  if length(VersionData)=0 then raise exception.create(GameName+' is not properly installed. Go to the Settings tab of Chaoslauncher, and set the path to '+GameName);
end;

//######## Settings ########

function LoadVersion:String;
var CurrentVersionName:String;
begin
  if (CurrentVersion>=0)and(CurrentVersion<length(VersionData))
    then CurrentVersionName:=VersionData[CurrentVersion].Name
    else CurrentVersionName:='';
  result:=ini.ReadString('Launcher','GameVersion',CurrentVersionName);
end;

procedure SaveVersion(const Version:String);
begin
  ini.WriteString('Launcher','GameVersion',Version);
end;

procedure LoadSize;
var ResizeEvent:TNotifyEvent;
begin
  ResizeEvent:=ChaoslauncherForm.OnResize;
  try
    ChaoslauncherForm.OnResize:=nil;
    ChaoslauncherForm.ClientWidth:=ini.ReadInteger('Launcher','Width',ChaoslauncherForm.ClientWidth);
    ChaoslauncherForm.ClientHeight:=ini.ReadInteger('Launcher','Height',ChaoslauncherForm.ClientHeight);
  finally
    ChaoslauncherForm.OnResize:=ResizeEvent;
  end;
end;

procedure TChaoslauncherForm.FormResize(Sender: TObject);
begin
  ini.WriteInteger('Launcher','Width',ChaoslauncherForm.ClientWidth);
  ini.WriteInteger('Launcher','Height',ChaoslauncherForm.ClientHeight);
end;

procedure TChaoslauncherForm.SetRunIfIncompatible(Value: boolean);
var Backup:TNotifyEvent;
begin
  Backup:=RunIfIncompatible.OnClick;
  try
    RunIfIncompatible.OnClick:=nil;
    RunIfIncompatible.checked:=value;
  finally
    RunIfIncompatible.OnClick:=Backup;
  end;
end;

procedure TChaoslauncherForm.SettingsChange(Sender: TObject);
begin
  SettingsChanged:=true;
  SettingsOk.Enabled:=true;
  SettingsCancel.Enabled:=true;
end;

procedure TChaoslauncherForm.SaveSettings(Sender: TObject);
var NeedsRestart:boolean;
begin
  Settings.StartMinimized:=StartMinimized.checked;
  Settings.MinimizeOnRun:=MinimizeOnRun.checked;
  Settings.RunScOnStartup:=RunScOnStartup.checked;
  Settings.AutoUpdate:=AutoUpdate.checked;
  Settings.WarnNoAdmin:=WarnNoAdmin.checked;
  Settings.GameDataPort:=strtoint(ScPort.text);
  Settings.AllowMultiInstance:=AllowMultiInstance.Checked;
  Settings.ddemulate:=ddemulate.Checked;

  NeedsRestart:=ScInstallPath.text<>GamePath;
  //SetGamePath(ScInstallPath.text);
  ScInstallPath.text:=GamePath;
  Settings.Save;
  SettingsOk.Enabled:=false;
  SettingsCancel.Enabled:=false;
  SettingsChanged:=false;
  GetScVersions(Sender);
  if NeedsRestart
    then begin
      RestartLauncher:=true;
      if MessageDlg('SC-Path changed. You should restart the launcher now.'#13#10
               +'Restart now?',
               mtConfirmation,
               [mbYes,mbNo],
               0)=mrYes
        then close
        else RestartLauncher:=false;
    end;
end;

procedure TChaoslauncherForm.LoadSettings(Sender: TObject);
begin
  Settings.Load;
  StartMinimized.checked:=Settings.StartMinimized;
  MinimizeOnRun.checked:=Settings.MinimizeOnRun;
  RunScOnStartup.checked:=Settings.RunScOnStartup;
  AutoUpdate.Checked:=Settings.Autoupdate;
  WarnNoAdmin.Checked:=Settings.WarnNoAdmin;
  ddemulate.Checked:=Settings.ddemulate;
  AllowMultiInstance.Checked:=Settings.AllowMultiInstance;

  ScInstallpath.text:=GamePath;
  ScPort.text:=inttostr(Settings.GameDataPort);

  SettingsChanged:=false;
  SettingsOk.Enabled:=false;
  SettingsCancel.Enabled:=false;
end;



//######## Update ########

Type TLauncherUpdateModule=class(TUpdateModule)
  public
    procedure CheckForUpdates(var desc:String);override;
end;

{ TLauncherUpdateModule }

procedure TLauncherUpdateModule.CheckForUpdates(var desc:String);
begin
  inherited;
  Log('Updateing Launcher');
end;

//######## SimpleGUI ########

procedure TChaoslauncherForm.About_WebsiteClick(Sender: TObject);
begin
end;

procedure TChaoslauncherForm.AppMinimize(Sender: TObject);
begin
  ChaoslauncherForm.Hide;
  //ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TChaoslauncherForm.AppRestore(Sender: TObject);
begin
  //if IsIconic(Application.Handle) then
  //  Application.Restore;
  ChaoslauncherForm.Show;
  //ShowWindow(Application.Handle, SW_SHOW);
  Application.BringToFront;
end;

procedure TChaoslauncherForm.ShowConfig(Sender: TObject);
begin
  ChaoslauncherForm.Show;
  Application.Restore;
  Application.BringToFront;
end;

procedure TChaoslauncherForm.ConfigClick(Sender: TObject);
begin
  if (Pluginlist.ItemIndex>high(PluginData))or(Pluginlist.ItemIndex<0) then exit;
  PluginData[PluginList.itemindex].showconfig;
end;

procedure TChaoslauncherForm.Exit1Click(Sender: TObject);
begin
  ChaoslauncherForm.Close;
end;

procedure TChaoslauncherForm.FormDestroy(Sender: TObject);
begin
  Log('Finishing');
end;


procedure TChaoslauncherForm.HelpClick(Sender: TObject);
var Filename:String;
begin
  Filename:='';
  if FileExistsUTF8(Changefileext(plugindata[pluginlist.ItemIndex].Filename,'.txt')) { *Converted from FileExists* }
    then Filename:=Changefileext(plugindata[pluginlist.ItemIndex].Filename,'.txt');
  if FileExistsUTF8(Changefileext(plugindata[pluginlist.ItemIndex].Filename,'Readme.txt')) { *Converted from FileExists* }
    then Filename:=Changefileext(plugindata[pluginlist.ItemIndex].Filename,'Readme.txt');
  if Filename<>'' then ShellExecute(0,'open',PChar(Filename),nil,nil,sw_normal);
end;

procedure TChaoslauncherForm.News_ChaosClick(Sender: TObject);
begin
end;

procedure TChaoslauncherForm.News_GGNetClick(Sender: TObject);
begin
end;

procedure TChaoslauncherForm.News_TLClick(Sender: TObject);
begin
end;

procedure TChaoslauncherForm.DiagnoseClick(Sender: TObject);
begin
  Log('GetDebugPrivilege');
  if not EnablePrivilege('SeDebugPrivilege')
    then showmessage('Could not obtain SeDebugPrivilege'#13#10+
             'Some plugins might not work correctly or cause errors'#13#10+
             'You need to be admin and if you are using vista you have to set the adminflag in the properties of Chaoslauncher.exe'#13#10+
             GetLastErrorString);
  if not FileExistsUTF8(GamePath+'Starcraft.exe') { *Converted from FileExists* }
    then showmessage('Incorrect path to starcraft'#13#10+
                     'Change it in the right column of the settings-tab');
  if lowercase(copy(GamePath,length(GamePath)-4,4))='.exe\' then
    showmessage('don''t include the name of the executable in the path');
end;

procedure TChaoslauncherForm.RunTool(Sender: TObject);
begin
  Tooldata[(Sender as TComponent).Tag].Run;
end;

procedure TChaoslauncherForm.RunTvAnts(Sender: TObject);
begin
  TvAntsData[(Sender as TComponent).tag].Run;
end;



procedure TChaoslauncherForm.GetTvAnts1Click(Sender: TObject);
var error:integer;
begin
  //error:=shellexecute(0,'open','http://www.tvants.com/download/tvantssetup.exe','','',SW_Normal);
  if error<=32 then raise exception.create('Error starting TvAnts '+inttostr(error));  
end;

procedure TChaoslauncherForm.WMShowInstance(var Message);
begin
  AppRestore(self);
end;

//######## Starting SC ########

procedure TChaoslauncherForm.Attach1Click(Sender: TObject);
var AProcessID:Cardinal;
begin
  UpdateSCRunning;
  if GameInfo.Running then raise exception.create(GameName+' already opened with Chaoslauncher');
  AProcessID:=GameFindProcessID;
  if AProcessID=0 then raise exception.create(GameName+' not running');
  if length(VersionData)=0 then raise exception.create(GameName+' is not properly installed. Go to the Settings tab of Chaoslauncher, and set the path to '+GameName);
  Log('Attach');
  StartGame(VersionData[CurrentVersion],AProcessID);
end;

procedure TChaoslauncherForm.BrowseInstallPathClick(Sender: TObject);
begin
  PathOpenDialog.filename:=ScInstallPath.Text+'Starcraft.exe';
  if PathOpenDialog.execute
    then ScInstallPath.Text:=extractfilepath(PathOpenDialog.filename);
end;

procedure TChaoslauncherForm.StartLatestSC(Sender: TObject);
begin
  Log('Start latest '+GameName);
  StartGame(VersionData[LatestVersion]);
  if Settings.MinimizeOnRun then ChaoslauncherForm.Hide;
end;

procedure TChaoslauncherForm.StartScVersion(Sender: TObject);
begin
  Log('Start '+GameName+' Version');
  StartGame(VersionData[TComponent(Sender).tag]);
  if Settings.MinimizeOnRun then ChaoslauncherForm.Hide;
end;

procedure TChaoslauncherForm.StartClick(Sender: TObject);
begin
  CheckGameVersions;
  Log('Startbutton');
  StartGame(VersionData[CurrentVersion]);
  if Settings.MinimizeOnRun then ChaoslauncherForm.Hide;
end;


//######## Init ########

procedure TChaoslauncherForm.ExceptionHandler(Sender: TObject; E: Exception);
begin
  ShowAndLogException(e,'Global ExceptionHandler');
end;

procedure TChaoslauncherForm.GetScVersions(Sender: TObject);
var i:integer;
    MenuItem:TMenuItem;
begin
  GetGameVersions(GamePath);
  Versions.items.clear;
  //RunScVersion1.Clear;
  //RunLadder1.Clear;
  for i := 0 to length(VersionData)-1 do
    begin
      Versions.Items.Add(VersionData[i].Name);
      //MenuItem:=TMenuItem.Create(RunScVersion1);
      //MenuItem.Caption:=versions.Items[i];
      //MenuItem.Tag:=i;
      //MenuItem.OnClick:=StartScVersion;
      //if VersionData[i].Ladder<>nil
      //  then RunLadder1.Add(MenuItem)
      //  else RunScVersion1.Add(MenuItem);
    end;
  CurrentVersion:=-1;
  CurrentVersion:=Versions.Items.IndexOf(LoadVersion);
  Versions.ItemIndex:=CurrentVersion;
  if Versions.ItemIndex<0
    then Versions.ItemIndex:=LatestVersion;
  //if LatestVersion>=0
  //  then RunSc1.caption:='&Run '+stringreplace(VersionData[LatestVersion].Name,GameName,GameShortName,[rfReplaceAll]);
  VersionsChange(Sender);
end;


procedure TChaoslauncherForm.FormCreate(Sender: TObject);
var   i,j:integer;
      sl:TStringlist;
begin
  Log('Begin Startup');
  Application.OnException:=ExceptionHandler;

  Log('Chaosauncher '+VersionToStr(GetProgramVersion)+' on '+GetWindowsVersionStr+' at '+paramstr(0));

  Log('GamePath: '+GamePath);

  Log('Load Plugins');
  LoadPlugins;

  Log('Load Tools');
  LoadTools;


  Log('Init GUI');
  Application.OnMinimize:=AppMinimize;
  Application.OnRestore:=AppRestore;
  PageControl1.ActivePageIndex:=0;
  PluginName.caption:='No Plugin';
  PluginVersion.caption:='';
  PluginAuthor.Caption:='';
  PluginDescription.text:='No Description';
  PluginStatus.caption:='';
  BanDanger.Caption:='';
  Config.enabled:=false;
  //ToolList.ItemIndex:=0;
  TLauncherUpdateModule.create(Updater);
  Pluginlist.items.clear;
  for i := 0 to length(PluginData)-1 do
    PluginList.items.add(PluginData[i].Name);
  //Pluginsettings
  sl:=nil;
  try
    sl:=TStringlist.Create;
    ini.ReadSection('PluginsEnabled',sl);
    for i := 0 to sl.count-1 do
      begin
        j:=Pluginlist.Items.IndexOf(sl[i]);
        if j<0 then continue;
        PluginData[j].RunIncompatible:=ini.ReadBool('PluginsRunIncompatible',Pluginlist.Items[j],false);
      end;
    for i:=0 to length(PluginData)-1do
      PluginData[i].LoadEnabled;
  finally
    sl.free;
  end;
  GetScVersions(Sender);
  PluginListClick(Sender);
  UpdatePluginList(sender);
  //About_Name.caption:=stringreplace('Chaoslauncher Version %1','%1',VersionToStr(GetProgramVersion),[rfReplaceAll]);
  LoadSize;
  Application.ShowMainForm:=false;
  visible:=not Settings.StartMinimized;
  if Settings.StartMinimized
    then Application.Minimize
    else Show;
  if not FileExistsUTF8(GamePath+'Starcraft.exe') { *Converted from FileExists* }
    then showmessage('Incorrect path to starcraft'#13#10+
                     'Change it in the right column of the settings-tab');
  if lowercase(copy(GamePath,length(GamePath)-4,4))='.exe\' then
    showmessage('don''t include the name of the executable in the path');
  Log('Init complete');
  StartupTimer.enabled:=true;
end;

//######## Pluginlist ########

procedure TChaoslauncherForm.UpdatePluginlist(Sender: TObject);
var i:integer;
begin
  for i := 0 to length(PluginData)-1 do
    begin
      if length(VersionData)>0
        then begin
          PluginList.ItemEnabled[i]:=PluginData[i].CouldRun(VersionData[CurrentVersion]);
          if PluginData[i].Compatible(VersionData[CurrentVersion])=coRequired then PluginData[i].Enabled:=true;
        end
        else PluginList.ItemEnabled[i]:=false;
      PluginList.Checked[i]:=PluginData[i].Enabled;
    end;
  PluginList.Invalidate;
end;

procedure TChaoslauncherForm.PluginlistClick(Sender: TObject);
var icon:integer;
    PluginVersionStr:String;
    Compatibility:TCompatibility;
    BanRisk:TBanRisk;
begin
  //Preconditions not realized
  if length(plugindata)=0 then exit;
  if length(versiondata)=0 then exit;

  if pluginlist.Items.Count=0 then exit;
  if pluginlist.ItemIndex<0 then pluginlist.ItemIndex:=0;

  //General Info
  PluginDescription.text:=plugindata[pluginlist.ItemIndex].Description;
  PluginName.caption:=plugindata[pluginlist.ItemIndex].Name;
  PluginVersionStr:=VersionToStr(plugindata[pluginlist.ItemIndex].Version);
  if PluginVersionStr<>''
    then PluginVersion.Caption:='Version '+PluginVersionStr
    else PluginVersion.Caption:='';
  if plugindata[pluginlist.ItemIndex].Author<>''
    then PluginAuthor.caption:='by '+plugindata[pluginlist.ItemIndex].Author
    else PluginAuthor.caption:='';
  Config.Enabled:=plugindata[pluginlist.ItemIndex].HasConfig;

  Help.Enabled:=
        FileExistsUTF8(Changefileext(plugindata[pluginlist.ItemIndex].Filename,'.txt')) { *Converted from FileExists* }
     or FileExistsUTF8(Changefileext(plugindata[pluginlist.ItemIndex].Filename,'Readme.txt')); { *Converted from FileExists* }

  //Pluginstate
  SetRunIfIncompatible(plugindata[pluginlist.ItemIndex].RunIncompatible);

  //Compatibility
  Compatibility:=plugindata[pluginlist.ItemIndex].Compatible(VersionData[currentversion]);
  PluginStatus.caption:=CompatibilityToStr(Compatibility);
  icon:=GetCompatiblityIcon(Compatibility);
  RunIfIncompatible.enabled:=Compatibility in [coIncompatible,coUnknown];
  if Compatibility=coRequired
    then plugindata[pluginlist.ItemIndex].Enabled:=true;

  //Set Compatibility picture
  PluginStatusImg.Picture.Graphic:=nil;
  PluginStatusImgs16.GetBitmap(icon,PluginStatusImg.Picture.Bitmap);
  PluginStatusImg.invalidate;

  //BanRisk
  BanRisk:=plugindata[pluginlist.ItemIndex].BanRisk;
  BanDanger.Caption:=BanRiskToStr(BanRisk);
  icon:=GetBanRiskIcon(BanRisk);

  //Set BanRisk picture
  BanDangerImg.Picture.Graphic:=nil;
  PluginStatusImgs16.GetBitmap(icon,BanDangerImg.Picture.Bitmap);
  BanDangerImg.invalidate;

end;

procedure TChaoslauncherForm.PluginlistClickCheck(Sender: TObject);
begin
  if (Pluginlist.ItemIndex>high(PluginData))or(Pluginlist.ItemIndex<0) then exit;
  if PluginData[Pluginlist.ItemIndex].Compatible(VersionData[currentversion])=coRequired
    then Pluginlist.checked[Pluginlist.ItemIndex]:=true;
  PluginData[Pluginlist.ItemIndex].enabled:=Pluginlist.checked[Pluginlist.ItemIndex];
  //Some plugins ignore changes to enabled
  Pluginlist.checked[Pluginlist.ItemIndex]:=PluginData[Pluginlist.ItemIndex].enabled;
end;

procedure TChaoslauncherForm.PluginlistDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  Flags: Longint;
  icon:integer;
begin
  PluginList.Canvas.FillRect(Rect);
  if Index < PluginList.Count then
    begin
      //DrawTextBiDiModeFlags(
      Flags := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
      if not UseRightToLeftAlignment then
        Inc(Rect.Left, 2)
      else
        Dec(Rect.Right, 2);
      if length(VersionData)>0
        then
          case PluginData[index].Compatible(VersionData[CurrentVersion])of
            coUnknown            : icon:=2;
            coForbidden          : icon:=2;
            coIncompatible       : icon:=2;
            coPartiallyCompatible: icon:=1;
            coCompatible         : icon:=-1;
            coRequired           : icon:=0;
            else                   icon:=2;
          end
         else icon:=-1;
      DrawText(PluginList.Canvas.Handle, PChar(PluginList.items[index]), Length(PluginList.items[index]), Rect, Flags);
      if (icon=2)and(length(VersionData)>0)and PluginData[index].CouldRun(VersionData[CurrentVersion])
        then icon:=3;//Run even if incompatible => RedIcon with green Check
      if icon>=0
        then PluginStatusImgs12.Draw(Pluginlist.Canvas,rect.Left+Canvas.TextWidth(PluginList.items[index])+1,rect.Top,icon);
    end;
end;

//######## Tools ########



//######## Misc ########

procedure TChaoslauncherForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   application.Restore;
   If ToolsChanged
   then begin
     CanClose:=false;
     messagedlg('Cannot close while editing a tool',mtWarning,[mbOk],0);
   end;
   If SettingsChanged
   then begin
     CanClose:=false;
     messagedlg('Cannot close while changing settings',mtWarning,[mbOk],0);
   end;
   UpdateScRunning;
   if GameInfo.Running
   then begin
     CanClose:=false;
     messagedlg('Cannot close while Starcraft is running',mtWarning,[mbOk],0);
   end;
   Application.Terminate;
end;

procedure TChaoslauncherForm.PageControl1Change(Sender: TObject);
begin

end;

procedure TChaoslauncherForm.PageControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
   If ToolsChanged
   then begin
     AllowChange:=false;
     messagedlg('Cannot swich tabs while editing a tool',mtWarning,[mbOk],0);
   end;
   If SettingsChanged
   then begin
     AllowChange:=false;
     messagedlg('Cannot swich tabs while changing settings',mtWarning,[mbOk],0);
   end;
end;

procedure TChaoslauncherForm.RunIfIncompatibleClick(Sender: TObject);
begin
  if RunIfIncompatible.checked then
    if MessageDlg('This settings allows running a plugin even if it reports that it is incompatible with the game version you are trying to run.'#13#10
                 +'It does NOT magically fix problems. Only enable this setting if you know what you are doing.'#13#10
                 +'Do you want to enable it anyways?',
                 mtConfirmation,
                 [mbYes,mbNo],
                 0,
                 mbNo)<>mrYes
      then SetRunIfIncompatible(false);
  if (Pluginlist.ItemIndex>high(PluginData))or(Pluginlist.ItemIndex<0) then exit;
  PluginData[Pluginlist.ItemIndex].RunIncompatible:=RunIfIncompatible.checked;
  ini.WriteBool('PluginsRunIncompatible',Pluginlist.Items[Pluginlist.ItemIndex],PluginData[Pluginlist.ItemIndex].RunIncompatible);
  UpdatePluginlist(sender);
end;

procedure TChaoslauncherForm.StartupTimerTimer(Sender: TObject);
begin
  StartupTimer.Enabled:=false;
  if Settings.RunScOnStartup
   then begin
     Log('Run Starcraft on startup');
     StartLatestSC(Sender);
   end;
end;

procedure TChaoslauncherForm.VersionsChange(Sender: TObject);
var CurrentVersionName:String;
begin
  CurrentVersion:=Versions.ItemIndex;
  if (CurrentVersion>=0)and(CurrentVersion<length(VersionData))
    then CurrentVersionName:=VersionData[CurrentVersion].Name
    else CurrentVersionName:='';
  SaveVersion(CurrentVersionName);
  PluginListClick(sender);
  UpdatePluginList(sender);
end;

end.
