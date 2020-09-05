@ECHO OFF


TITLE EternalModInjector.bat    (2020-08-19)
ECHO/
ECHO 	[44;96m                                             [0m
ECHO 	[44;96m  EternalModInjector.bat                     [0m
ECHO 	[44;96m      by Zwip-Zwap Zapony, dated 2020-08-19  [0m
ECHO 	[44;96m                                             [0m
ECHO/
ECHO/


2>NUL VERIFY/
SETLOCAL ENABLEEXTENSIONS

IF ERRORLEVEL 1 (
	ECHO 	[1;41;93mERROR: Command Processor Extensions are unavailable![0m
	ECHO/
	ECHO 	This batch file requires command extensions, but they seem to be unavailable on your system.
	ECHO/
	PAUSE
	EXIT /B 1
)
IF NOT CMDEXTVERSION 2 (
	ECHO 	[1;41;93mERROR: Command Processor Extensions are of version 1![0m
	ECHO/
	ECHO 	Command extensions seem to be available on your system, but only of version 1. This batch file was designed for version 2.
	ECHO/
	PAUSE
	EXIT /B 1
)


SET ___CONFIGURATION_FILE=EternalModInjector.dat
SET ___GAME_EXE=DOOMEternalx64vk.exe

SET ___ASSET_VERSION=2.1

SET ___CONFIGURATION_EXISTS=
SET ___GAME_PARAMETERS=
SET ___HAS_CHECKED_RESOURCES=
SET ___HAS_READ_FIRST_TIME=
SET ___RESET_BACKUPS=
CALL :FunctionCallForResources :FunctionInitializeBackupVariable
CALL :FunctionCallForResources :FunctionInitializeModdedVariable





IF EXIST ".\%___CONFIGURATION_FILE%" GOTO ConfigurationFile
:PostConfigurationFile


IF DEFINED ___RESET_BACKUPS GOTO ResetBackups
:PostResetBackups


GOTO CheckForNeededFiles
:PostCheckForNeededFiles


IF NOT DEFINED ___HAS_READ_FIRST_TIME GOTO FirstTimeInformation
:PostFirstTimeInformation


IF DEFINED ___CONFIGURATION_EXISTS GOTO RestoreArchives
:PostRestoreArchives


GOTO ModLoader





:ConfigurationFile
ECHO 	Loading configuration file... (%___CONFIGURATION_FILE:\=/%)
SET ___CONFIGURATION_EXISTS=1


SET ___RESET_BACKUPS=2
SET ___TEMP=
FOR /F "delims=" %%A IN ('FINDSTR "\<:ASSET_VERSION=" ".\%___CONFIGURATION_FILE%"') DO SET ___TEMP=%%A
IF "%___ASSET_VERSION%"=="%___TEMP:~15%" SET ___RESET_BACKUPS=

SET ___TEMP=
FOR /F "delims=" %%A IN ('FINDSTR "\<:GAME_PARAMETERS=" ".\%___CONFIGURATION_FILE%"') DO SET ___TEMP=%%A
IF DEFINED ___TEMP SET ___GAME_PARAMETERS=%___TEMP:~17%

>NUL 2>&1 FIND /C ":HAS_CHECKED_RESOURCES=1" ".\%___CONFIGURATION_FILE%"
IF NOT ERRORLEVEL 1 SET ___HAS_CHECKED_RESOURCES=1

>NUL 2>&1 FIND /C ":HAS_READ_FIRST_TIME=1" ".\%___CONFIGURATION_FILE%"
IF NOT ERRORLEVEL 1 SET ___HAS_READ_FIRST_TIME=1

>NUL 2>&1 FIND /C ":RESET_BACKUPS=1" ".\%___CONFIGURATION_FILE%"
IF NOT ERRORLEVEL 1 SET ___RESET_BACKUPS=1

CALL :FunctionCallForResources :FunctionSetResourceVariable

GOTO PostConfigurationFile
IF NOT ERRORLEVEL 1 IF NOT DEFINED ___RESET_BACKUPS SET ___RESET_BACKUPS=1


:FunctionSetResourceVariable
>NUL 2>&1 FIND /C "%~n1.backup" ".\%___CONFIGURATION_FILE%"
IF NOT ERRORLEVEL 1 SET ___BACKED_UP_%~n1=1

>NUL 2>&1 FIND /C "%~n1.resources" ".\%___CONFIGURATION_FILE%"
IF NOT ERRORLEVEL 1 SET ___MODDED_%~n1=1

EXIT /B 0





:ResetBackups
IF ___RESET_BACKUPS==2 GOTO ResetBackupsAssetUpdate

ECHO/
ECHO/
ECHO 	":RESET_BACKUPS" is currently set to "1" in "%___CONFIGURATION_FILE:\=/%".
ECHO/
ECHO 	Do you want to reset the current .resources backups?
ECHO/
ECHO/
ECHO (Press [1m[Y][0m to delete the current backup files.)
ECHO (Press [1m[N][0m to keep the current backups.)
ECHO (Press [1m[I][0m for more information.)
<NUL SET /P ="(Press [1m[Ctrl+C][0m to close this batch file without changes.) "
CHOICE /C YNI /N
ECHO/
ECHO/

IF NOT ERRORLEVEL 1 EXIT /B 1
IF ERRORLEVEL 4 EXIT /B 1

IF ERRORLEVEL 3 GOTO ResetBackupsInformation
IF ERRORLEVEL 2 GOTO ResetBackupsNo

:ResetBackupsYes
ECHO 	Deleting backups...

SET ___HAS_CHECKED_RESOURCES=
CALL :FunctionCallForResources :FunctionDeleteBackup
CALL :FunctionWriteConfiguration

ECHO 	The backups have been deleted.

CALL :FunctionCheckIfModsExist
IF NOT ERRORLEVEL 1 (
	ECHO 	No mods were found in the "Mods" folder, so this batch file will close now.
	ECHO/
	PAUSE
	EXIT /B 1
)

:ResetBackupsYesY
ECHO 	Would you like to install mods now?
ECHO/
ECHO (Press [1m[Y][0m to install mods.)
:ResetBackupsYesN
<NUL SET /P ="(Press [1m[N][0m to close this batch file.) "
CHOICE /C YN /N
IF NOT ERRORLEVEL 1 EXIT /B 1
IF ERRORLEVEL 2 EXIT /B 1
GOTO PostResetBackups


:ResetBackupsNo
CALL :FunctionWriteConfiguration
ECHO 	The backups have been kept as they were.

CALL :FunctionCheckIfModsExist
IF ERRORLEVEL 1 GOTO ResetBackupsYesY

ECHO 	Would you like to uninstall mods now?
ECHO/
ECHO (Press [1m[Y][0m to uninstall mods.^)
GOTO ResetBackupsYesN


:ResetBackupsInformation
ECHO/
ECHO/
ECHO 	More information:
ECHO/
ECHO 	DOOM Eternal mods are applied to the game's .resources files.
ECHO 	Since they're applied to existing .resources files, not brand-new files, it's necessary to have backups of the original/default/vanilla .resources files.
ECHO 	The backups are used to restore the vanilla .resources files, so that you can avoid unwanted mods' changes being kept when you try to uninstall a mod.
ECHO 	This batch file automatically handles the backup and restoration process for you, backing up .resources files the first time that they're about to be modified, and restoring them the next time that you run this batch file.
ECHO/
ECHO/
PAUSE

ECHO/
ECHO/
ECHO/
ECHO/
ECHO 	However, if the backups are outdated or already-modified, it's wise to reset them, in order to make new, up-to-date backups.
ECHO 	(This should only be done when the current .resources files are original/default/vanilla/non-modified, so make sure to re-download the original files through Steam or the Bethesda.net Launcher first.^)
ECHO/
ECHO 	When the ":RESET_BACKUPS=0" line is changed from "0" to "1" in -/DOOMEternal/%___CONFIGURATION_FILE:\=/%, you will be asked if you'd like to reset this batch file's backups, and in what way.
ECHO 	There are 3 options as to how to handle it:
ECHO/
ECHO/
PAUSE

ECHO/
ECHO/
ECHO/
ECHO/
ECHO 	With the [1m[Y][0m option, the backup files will be deleted from the disk (freeing some filespace^), and then new backups will be made (taking up the filespace again^) the next first time that you install a mod for a .resources file.
ECHO/
ECHO 	With the [1m[N][0m option, the current backup files will remain on the disk, and they will continue to be used (without updating them^).
ECHO/
ECHO 	With the [1m[Ctrl+C][0m option, this batch file will close without doing any changes anywhere.
ECHO/
ECHO/
PAUSE

ECHO/
ECHO/
ECHO (Press [1m[Y][0m, [1m[N][0m, or [1m[Ctrl+C][0m.
CHOICE /C YN /N /M "See above for what the options do.^)"
ECHO/
ECHO/

IF NOT ERRORLEVEL 1 EXIT /B 1
IF ERRORLEVEL 3 EXIT /B 1

IF ERRORLEVEL 2 GOTO :ResetBackupsNo
GOTO :ResetBackupsYes



:ResetBackupsAssetUpdate
GOTO PostResetBackups

ECHO/
ECHO/
ECHO 	This batch file has been updated for a new version of DOOM Eternal since you last used it.
ECHO 	By extension, this implies that DOOM Eternal has been updated, and so the .resources backups must be updated too.
ECHO/
ECHO 	Make sure to re-download the original game files through Steam or the Bethesda.net Launcher before continuing.
ECHO/
ECHO/
ECHO (After re-downloading the original game files, press [1m[Y][0m to delete the current backup files.)
ECHO (Press [1m[I][0m for instructions on re-downloading the original game files.)
<NUL SET /P ="(Press [1m[Ctrl+C][0m to close this batch file without changes.) "
CHOICE /C YI /N
ECHO/
ECHO/

IF NOT ERRORLEVEL 1 EXIT /B 1
IF ERRORLEVEL 3 EXIT /B 1

IF NOT ERRORLEVEL 2 GOTO ResetBackupsYes

:ResetBackupsAssetUpdateInformation
ECHO/
ECHO/
ECHO 	To re-download the original files using Steam, right-click DOOM Eternal in your Steam library, choose "Properties" ^> "Local Files" ^> "Verify Integrity of Game Files...", and wait for Steam to re-download the default files.
ECHO/
ECHO 	To re-download the original files using the Bethesda.net Launcher, click on DOOM Eternal's game icon in the launcher, click "Game Options" near the top-right, choose "Scan and Repair", and wait for the Bethesda.net Launcher to re-download the default files.
ECHO/
ECHO/
PAUSE

ECHO/
ECHO/
ECHO/
ECHO/
ECHO 	After having re-downloaded the original game files, press [1m[Y][0m to delete the current backup files.
ECHO/
ECHO 	If you'd rather re-download them later instead of now, you can instead press [1m[Ctrl+C][0m to close this batch file without changes.
ECHO/
ECHO/
ECHO (Press [1m[Y][0m or [1m[Ctrl+C][0m.
CHOICE /C Y /N /M "See above for what the options do.^)"
ECHO/
ECHO/

IF NOT ERRORLEVEL 1 EXIT /B 1
IF ERRORLEVEL 2 EXIT /B 1

GOTO ResetBackupsYes


:FunctionDeleteBackup
SET ___MODDED_%~n1=
IF NOT DEFINED ___BACKED_UP_%~n1 EXIT /B 0

SET ___BACKED_UP_%~n1=
IF EXIST ".\base\%~1.resources.backup" (
	ECHO 	Deleting %~n1.resources.backup...
	>NUL DEL ".\base\%~1.resources.backup"
) ELSE (
	ECHO 	%~n1.resources.backup was already deleted...
)
EXIT /B 0





:CheckForNeededFiles
ECHO 	Checking for needed files...
CALL :FunctionCheckForVanillaFile %___GAME_EXE%
IF ERRORLEVEL 1 EXIT /B 1
CALL :FunctionCheckForVanillaFile base\build-manifest.bin
IF ERRORLEVEL 1 EXIT /B 1
IF DEFINED ___HAS_CHECKED_RESOURCES (
	CALL :FunctionCheckForResourceFile meta
) ELSE (
	SET ___HAS_CHECKED_RESOURCES=1
	CALL :FunctionCallForResources :FunctionCheckForResourceFile
)
IF ERRORLEVEL 1 EXIT /B 1
CALL :FunctionCheckForToolFile DEternal_loadMods.exe
IF ERRORLEVEL 1 EXIT /B 1
CALL :FunctionCheckForToolFile EternalPatcher.exe
IF ERRORLEVEL 1 EXIT /B 1
CALL :FunctionCheckForToolFile base\idRehash.exe
IF ERRORLEVEL 1 EXIT /B 1
CALL :FunctionCheckForModsFolder
IF ERRORLEVEL 1 EXIT /B 1
CALL :FunctionCallForResources :FunctionCheckForBackupFile
IF ERRORLEVEL 1 EXIT /B 1

GOTO PostCheckForNeededFiles


:FunctionCheckForBackupFile
IF NOT DEFINED ___MODDED_%~n1 EXIT /B 0
IF NOT DEFINED ___BACKED_UP_%~n1 EXIT /B 0
IF EXIST ".\base\%~1.resources.backup" EXIT /B 0

SET ___TEMP=%~1
CALL :FunctionEchoError "%~n1.resources.backup" not found!
ECHO/
ECHO 	%~n1.resources.backup should be located at -/DOOMEternal/base/%___TEMP:\=/%.resources.backup, but it's missing!
ECHO/
ECHO 	Please re-download the original game files through Steam or the Bethesda.net Launcher, open "%___CONFIGURATION_FILE:\=/%" in Notepad, change ":RESET_BACKUPS=0" to ":RESET_BACKUPS=1", save the file, and choose to update the backup files the next time that you run this batch file.
ECHO/
ECHO/
ECHO 	To re-download the original files using Steam, right-click DOOM Eternal in your Steam library, choose "Properties" ^> "Local Files" ^> "Verify Integrity of Game Files...", and wait for Steam to re-download the default files.
ECHO/
ECHO 	To re-download the original files using the Bethesda.net Launcher, click on DOOM Eternal's game icon in the launcher, click "Game Options" near the top-right, choose "Scan and Repair", and wait for the Bethesda.net Launcher to re-download the default files.
ECHO/
PAUSE
EXIT /B 1


:FunctionCheckForModsFolder
IF EXIST ".\Mods\" EXIT /B 0
CALL :FunctionEchoError "Mods" not found!
ECHO/
ECHO 	Did you misplace this batch file, or did you forget to make a "Mods" folder?
ECHO 	The "Mods" folder should be located at -/DOOMEternal/Mods/
ECHO 	This batch file should be located at -/DOOMEternal/EternalModInjector.bat
ECHO/
ECHO 	If you're trying to uninstall mods, just make an empty "Mods" folder, then run this batch file again.
ECHO/
PAUSE
EXIT /B 1


:FunctionCheckForResourceFile
IF EXIST ".\base\%~1.resources" EXIT /B 0
SET ___TEMP=%~1
CALL :FunctionEchoError "%~n1.resources" not found!
ECHO/
ECHO 	Did you misplace this batch file, or is your DOOM Eternal installation incomplete?
ECHO 	%~n1.resources should be located at -/DOOMEternal/base/%___TEMP:\=/%.resources
ECHO 	This batch file should be located at -/DOOMEternal/EternalModInjector.bat
ECHO/
PAUSE
EXIT /B 1


:FunctionCheckForToolFile
IF EXIST ".\%~1" EXIT /B 0
SET ___TEMP=%~1
CALL :FunctionEchoError "%~nx1" not found!
ECHO/
ECHO 	Did you misplace %~n1 or this batch file, or did you forget to install %~n1?
ECHO 	%~nx1 should be located at -/DOOMEternal/%___TEMP:\=/%
ECHO 	This batch file should be located at -/DOOMEternal/EternalModInjector.bat
ECHO/
PAUSE
EXIT /B 1


:FunctionCheckForVanillaFile
IF EXIST ".\%~1" EXIT /B 0
SET ___TEMP=%~1
CALL :FunctionEchoError "%~nx1" not found!
ECHO/
ECHO 	Did you misplace this batch file, or is your DOOM Eternal installation incomplete?
ECHO 	%~nx1 should be located at -/DOOMEternal/%___TEMP:\=/%
ECHO 	This batch file should be located at -/DOOMEternal/EternalModInjector.bat
ECHO/
PAUSE
EXIT /B 1





:FirstTimeInformation
ECHO/
ECHO/
ECHO 	First-time information:
ECHO/
ECHO 	This batch file automatically...
ECHO 	- Makes backups of DOOM Eternal's .resources files the first time that they will be modified.
ECHO 	- Restores ones that were modified last time (to prevent uninstalled mods from lingering around) on subsequent uses.
ECHO 	- Runs DEternal_loadMods to load all mods in -/DOOMEternal/Mods/.
ECHO 	- Runs idRehash to rehash the modified resources' hashes.
ECHO 	- Runs EternalPatcher to apply EXE patches to DOOM Eternal's game executable.
ECHO 	- Launches DOOM Eternal for you once that's all done.
ECHO/
ECHO/
PAUSE

ECHO/
ECHO/
ECHO/
ECHO/
ECHO 	I, Zwip-Zwap Zapony, take no credit for the creation of any of those things, only of this batch file that runs those things.
ECHO/
ECHO 	Full credits go to...
ECHO 	DEternal_loadMods: SutandoTsukai181 for making it (based on a QuickBMS-based unpacker made for Wolfenstein II: The New Colossus by aluigi and edited for DOOM Eternal by one of infogram's friends)
ECHO 	EternalPatcher: proteh for making it (based on EXE patches made by infogram that were based on Cheat Engine patches made by SunBeam, as well as based on EXE patches made by Visual Studio)
ECHO 	idRehash: infogram for making it, and proteh for updating it
ECHO 	DOOM Eternal: Bethesda Softworks, id Software, and everyone else involved, for making and updating it
ECHO/
ECHO/
PAUSE

ECHO/
ECHO/
ECHO/
ECHO/
ECHO 	If any mods are currently installed and/or you have some outdated files when EternalModInjector makes .resources backups, the subsequent backups will contain those mods and/or be outdated.
ECHO 	Don't worry, though; If you ever mess up in a way that results in an already-modified/outdated backup, simply re-download the original files, open "%___CONFIGURATION_FILE:\=/%" in Notepad, change the ":RESET_BACKUPS=0" line to ":RESET_BACKUPS=1", and save the file.
ECHO/
ECHO/
ECHO 	To re-download the original files using Steam, right-click DOOM Eternal in your Steam library, choose "Properties" ^> "Local Files" ^> "Verify Integrity of Game Files...", and wait for Steam to re-download the default files.
ECHO/
ECHO 	To re-download the original files using the Bethesda.net Launcher, click on DOOM Eternal's game icon in the launcher, click "Game Options" near the top-right, choose "Scan and Repair", and wait for the Bethesda.net Launcher to re-download the default files.
ECHO/
ECHO/
PAUSE

ECHO/
ECHO/
ECHO/
ECHO/
ECHO 	Now, without further ado, press any key to continue one last time, and this batch file will initiate mod-loading mode.
ECHO/
ECHO/
PAUSE

CALL :FunctionWriteConfiguration
ECHO/
ECHO/
GOTO PostFirstTimeInformation





:RestoreArchives
SET ___TEMP=
CALL :FunctionCallForResources :FunctionRestoreArchive
IF ERRORLEVEL 1 EXIT /B 1
GOTO PostRestoreArchives


:FunctionRestoreArchive
IF NOT DEFINED ___MODDED_%~n1 EXIT /B 0

SET ___MODDED_%~n1=

IF NOT DEFINED ___TEMP (
	ECHO 	Restoring modified .resources archives...
	SET ___TEMP=1
)
IF NOT DEFINED ___BACKED_UP_%~n1 GOTO FunctionRestoreArchiveNoBackup

ECHO 		Restoring "%~n1.resources"...
>NUL COPY /Y ".\base\%~1.resources.backup" ".\base\%~1.resources"
IF NOT ERRORLEVEL 1 EXIT /B 0

CALL :FunctionWriteConfiguration

SET ___TEMP=%~1
CALL :FunctionEchoError "%~n1.resources" couldn't be restored!
ECHO/
ECHO 	Something went wrong while trying to copy -/DOOMEternal/base/%___TEMP:\=/%.resources.backup to -/DOOMEternal/base/%___TEMP:\=/%.resources.
ECHO/
ECHO 	Please make sure that neither of the files are in use by another program (such as DOOM Eternal itself, Steam, the Bethesda.net Launcher, or other software), then run this batch file again.
ECHO/
PAUSE
EXIT /B 1


:FunctionRestoreArchiveNoBackup
CALL :FunctionEchoError "%~n1.resources" was modified last time, but is not backed up!
ECHO/
ECHO 	Please re-download the original game files through Steam or the Bethesda.net Launcher, open "%___CONFIGURATION_FILE:\=/%" in Notepad, change ":RESET_BACKUPS=0" to ":RESET_BACKUPS=1", save the file, and choose to update the backup files the next time that you run this batch file.
ECHO/
ECHO/
ECHO 	To re-download the original files using Steam, right-click DOOM Eternal in your Steam library, choose "Properties" ^> "Local Files" ^> "Verify Integrity of Game Files...", and wait for Steam to re-download the default files.
ECHO/
ECHO 	To re-download the original files using the Bethesda.net Launcher, click on DOOM Eternal's game icon in the launcher, click "Game Options" near the top-right, choose "Scan and Repair", and wait for the Bethesda.net Launcher to re-download the default files.
ECHO/
PAUSE
EXIT /B 1





:ModLoader
ECHO 	Checking for mods... (DEternal_loadMods)

SETLOCAL ENABLEDELAYEDEXPANSION
SET ___WILL_BE_MODDED=:
FOR /F "delims=" %%A IN ('.\DEternal_loadMods.exe --list-res') DO SET ___WILL_BE_MODDED=!___WILL_BE_MODDED!%%A:
ENDLOCAL & SET ___WILL_BE_MODDED=%___WILL_BE_MODDED%

ECHO %___WILL_BE_MODDED%| >NUL 2>&1 FIND /C ".resources:"
IF ERRORLEVEL 1 GOTO ModLoaderModsDontExist

SET ___WILL_BE_MODDED=%___WILL_BE_MODDED%meta.resources:
SET ___TEMP=
CALL :FunctionCallForResources :FunctionBackUpArchive
IF ERRORLEVEL 1 EXIT /B 1
CALL :FunctionWriteConfiguration

ECHO 	Getting vanilla resource hash offsets... (idRehash)
START "" /D ".\base" /MIN /WAIT ".\base\idRehash.exe" --getoffsets
IF ERRORLEVEL 1 GOTO ModLoaderGetHashError

ECHO 	Loading mods... (DEternal_loadMods)
.\DEternal_loadMods.exe "%CD%"
IF NOT ERRORLEVEL 0 GOTO ModLoaderModsError
IF ERRORLEVEL 1 GOTO ModLoaderModsError

ECHO 	Rehashing resource hashes... (idRehash)
START "" /D ".\base" /MIN /WAIT ".\base\idRehash.exe"
IF ERRORLEVEL 1 GOTO ModLoaderRehashError

GOTO ModLoaderLaunchGame


:ModLoaderModsDontExist
ECHO 		No mods were found in the "Mods" folder...
ECHO 		The .resources archives were restored, so mods should be uninstalled now...


:ModLoaderLaunchGame
ECHO 	Checking online for new game EXE patches... (EternalPatcher)
START "" /MIN /WAIT ".\EternalPatcher.exe" --update
ECHO 	Applying game EXE patches, whether or not new/updated ones were found... (EternalPatcher)
START "" /MIN /WAIT ".\EternalPatcher.exe" --patch ".\%___GAME_EXE%"
ECHO/
ECHO/
IF DEFINED ___GAME_PARAMETERS (
	START "" ".\%___GAME_EXE%" %* %___GAME_PARAMETERS%
) ELSE (
	START "" ".\%___GAME_EXE%" %*
)
ECHO 	DOOM Eternal has been launched!
ECHO/
ECHO 	This batch file will auto-close in 5 seconds.
ECHO 	Press [Ctrl+C] to keep it open to view the batch output above.
>NUL TIMEOUT /T 5 /NOBREAK
EXIT /B 0


:ModLoaderGetHashError
ECHO/
ECHO/
CALL :FunctionEchoError idRehash couldn't find the resource hash offsets!
ECHO/
ECHO 	Try rebooting your computer and running this batch file again afterwards.
ECHO 	If that doesn't work, make sure that your copy of idRehash is up-to-date.
ECHO/
PAUSE
EXIT /B 1


:ModLoaderModsError
ECHO/
ECHO/
CALL :FunctionEchoError DEternal_loadMods didn't work!
ECHO/
ECHO 	Make sure that you use -/DOOMEternal/Mods[1;4m/gameresources/[0m-, not just -/DOOMEternal/Mods[1;4m/[0m-, for loose/extracted mod files.
ECHO 	(Zip-archive mods should still just be in -/DOOMEternal/Mods/; only loose/extracted mods should be in a "gameresources" sub-folder.)
ECHO 	Additionally, make sure that none of the .resources archives are in use by another program (such as DOOM Eternal itself, Steam, the Bethesda.net Launcher, or other software), then run this batch file again.
ECHO/
ECHO 	You may also run into other problems than that, which won't be covered here.
ECHO 	In such cases, try rebooting your computer and running this batch file again afterwards.
ECHO/
PAUSE
EXIT /B 1


:ModLoaderRehashError
ECHO/
ECHO/
CALL :FunctionEchoError idRehash couldn't generate new resource hashes!
ECHO/
ECHO 	Try rebooting your computer and running this batch file again afterwards.
ECHO 	If that doesn't work, make sure that your copy of idRehash is up-to-date.
ECHO/
PAUSE
EXIT /B 1


:FunctionBackUpArchive
ECHO %___WILL_BE_MODDED%| >NUL 2>&1 FIND /C ":%~n1.resources:"
IF ERRORLEVEL 1 EXIT /B 0

SET ___MODDED_%~n1=1

IF DEFINED ___BACKED_UP_%~n1 EXIT /B 0

IF NOT DEFINED ___TEMP (
	ECHO 		Backing up .resources archives...
	SET ___TEMP=1
)

SET ___BACKED_UP_%~n1=1
ECHO 			Backing up "%~n1.resources"...
>NUL COPY /Y ".\base\%~1.resources" ".\base\%~1.resources.backup"
IF NOT ERRORLEVEL 1 EXIT /B 0

SET ___BACKED_UP_%~n1=
CALL :FunctionCallForResources :FunctionInitializeModdedVariable
CALL :FunctionWriteConfiguration

SET ___TEMP=%~1
CALL :FunctionEchoError "%~n1.resources" couldn't be backed up!
ECHO/
ECHO 	Something went wrong while trying to copy -/DOOMEternal/base/%___TEMP:\=/%.resources to -/DOOMEternal/base/%___TEMP:\=/%.resources.backup.
ECHO/
ECHO 	Please make sure that neither of the files are in use by another program (such as DOOM Eternal itself, Steam, the Bethesda.net Launcher, or other software), then run this batch file again.
ECHO/
PAUSE
EXIT /B 1





:FunctionCallForResources
CALL %1 game\sp\e1m1_intro\e1m1_intro
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m1_intro\e1m1_intro_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m1_intro\e1m1_intro_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m2_battle\e1m2_battle
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m2_battle\e1m2_battle_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m2_battle\e1m2_battle_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m3_cult\e1m3_cult
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m3_cult\e1m3_cult_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m3_cult\e1m3_cult_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m4_boss\e1m4_boss
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m4_boss\e1m4_boss_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e1m4_boss\e1m4_boss_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m1_nest\e2m1_nest
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m1_nest\e2m1_nest_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m1_nest\e2m1_nest_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m2_base\e2m2_base
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m2_base\e2m2_base_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m2_base\e2m2_base_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m3_core\e2m3_core
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m3_core\e2m3_core_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m3_core\e2m3_core_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m4_boss\e2m4_boss
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e2m4_boss\e2m4_boss_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m1_slayer\e3m1_slayer
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m1_slayer\e3m1_slayer_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m1_slayer\e3m1_slayer_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m2_hell\e3m2_hell
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m2_hell\e3m2_hell_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m2_hell\e3m2_hell_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m2_hell_b\e3m2_hell_b
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m2_hell_b\e3m2_hell_b_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m2_hell_b\e3m2_hell_b_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m3_maykr\e3m3_maykr
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m3_maykr\e3m3_maykr_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m3_maykr\e3m3_maykr_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m4_boss\e3m4_boss
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m4_boss\e3m4_boss_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\sp\e3m4_boss\e3m4_boss_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 gameresources
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 gameresources_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 gameresources_patch2
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\hub\hub
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\hub\hub_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 meta
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_bronco\pvp_bronco
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_bronco\pvp_bronco_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_deathvalley\pvp_deathvalley
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_deathvalley\pvp_deathvalley_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_inferno\pvp_inferno
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_inferno\pvp_inferno_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_laser\pvp_laser
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_laser\pvp_laser_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_shrapnel\pvp_shrapnel
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_shrapnel\pvp_shrapnel_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_thunder\pvp_thunder
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_thunder\pvp_thunder_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_zap\pvp_zap
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\pvp\pvp_zap\pvp_zap_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\shell\shell
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\tutorials\tutorial_demons
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\tutorials\tutorial_pvp_laser\tutorial_pvp_laser
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 game\tutorials\tutorial_pvp_laser\tutorial_pvp_laser_patch1
IF ERRORLEVEL 1 EXIT /B 1
CALL %1 warehouse
IF ERRORLEVEL 1 EXIT /B 1

EXIT /B 0


:FunctionCheckIfModsExist
FOR %%A IN (".\Mods\*") DO EXIT /B 1
FOR /D %%A IN (".\Mods\*") DO EXIT /B 1
EXIT /B 0


:FunctionEchoError
ECHO 	[1;41;93mERROR: %*[0m
EXIT /B 0


:FunctionInitializeBackupVariable
SET ___BACKED_UP_%~n1=
EXIT /B 0


:FunctionInitializeModdedVariable
SET ___MODDED_%~n1=
EXIT /B 0


:FunctionWriteConfiguration
>.\%___CONFIGURATION_FILE% ECHO :ASSET_VERSION=%___ASSET_VERSION%
IF DEFINED ___GAME_PARAMETERS (
	>>.\%___CONFIGURATION_FILE% ECHO :GAME_PARAMETERS=%___GAME_PARAMETERS%
) ELSE (
	>>.\%___CONFIGURATION_FILE% ECHO :GAME_PARAMETERS=
)
IF DEFINED ___HAS_CHECKED_RESOURCES (
	>>.\%___CONFIGURATION_FILE% ECHO :HAS_CHECKED_RESOURCES=1
) ELSE (
	>>.\%___CONFIGURATION_FILE% ECHO :HAS_CHECKED_RESOURCES=0
)
>>.\%___CONFIGURATION_FILE% ECHO :HAS_READ_FIRST_TIME=1
>>.\%___CONFIGURATION_FILE% ECHO :RESET_BACKUPS=0
CALL :FunctionCallForResources :FunctionWriteConfigurationResources
EXIT /B 0

:FunctionWriteConfigurationResources
IF DEFINED ___BACKED_UP_%~n1 >>.\%___CONFIGURATION_FILE% ECHO %~n1.backup
IF DEFINED ___MODDED_%~n1    >>.\%___CONFIGURATION_FILE% ECHO %~n1.resources
EXIT /B 0