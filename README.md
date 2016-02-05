# Chaoslauncher

Updated version of MasterOfChaos' ChaosLauncher that can now compile using Lazarus IDE.

Has a lot of functionality removed (mostly things that need net-code, such as remote updating of plugins).

A lot of the interface is removed too (Only Plugins and Settings pages survive). No more Tools or About or Calendar.

Will (soon) move all settings from the registry to a local .ini file, to allow for multiple instances of ChaosLauncher to have different settings.

WARNING: StarCraft directory currently hard-coded in Launcher_Game.pas, on line 46. You might want to change that.

# Compiling

With Lazarus, open \Source\Launcher\LauncherChaoslauncher.lpi. Build / run. The result will be in \Source\Launcher\Launcher\Build.

# Have fun!
