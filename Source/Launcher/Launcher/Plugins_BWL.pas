unit Plugins_BWL;

interface
uses update;
procedure BwlUpdateCheck(AUpdater:TUpdater;Url,Filename:String;var desc:String;const PluginName:String);

implementation
uses classes,versions,logger,util,sysutils,crypto;

procedure BwlUpdateCheck(AUpdater:TUpdater;Url,Filename:String;var desc:String;const PluginName:String);
var
    sl:TStringlist;
    Version:TVersion;
    i:integer;
    compressed:boolean;
begin

end;

end.
