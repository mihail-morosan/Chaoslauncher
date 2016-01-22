unit Inject;

{$MODE Delphi}

interface
uses Plugins, FileUtil;

Type TInjectionMethod=(imOverwrite);
procedure SaveInjectInfo(const Version:TGameVersion);

implementation
uses windows,classes,sysutils,Util,Inject_Overwrite,streaming;
const InjectionHelper='ChaosInjector.dll';

procedure SaveInjectInfo(const Version:TGameVersion);
var stm:TFileStream;
begin
  stm:=nil;
  try
    if not FileExistsUTF8(LauncherInfo.Path+InjectionHelper) { *Converted from FileExists* }
      then raise exception.Create('Injectionhelper ('+InjectionHelper+') not found');
    if GetFileVersion(paramstr(0))<>GetFileVersion(LauncherInfo.Path+Injectionhelper)
      then raise exception.Create('Incompatible Injectionhelper version');
    Stm:=TFileStream.Create(changefileext(LauncherInfo.Path+injectionhelper,'.chio'),fmCreate or fmShareExclusive);
  finally
    stm.free;
  end;
end;


end.
