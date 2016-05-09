If (Test-Path HostOutput.csv){
	Remove-Item HostOutput.csv
}
new-item HostOutput.csv -type file


#function tests if the host is reachable by IP
function netstate
{
    $TESTCON = Test-Connection $args[0] -count 1 -Quiet -ErrorAction SilentlyContinue
    if($TESTCON -eq $true)
    {
        return "Up"
    }
    else
    {
        return "Down"
    }
}  

#converting the hostname to an IP address through Ping
function host2ip
{
    $TESTCON = Test-Connection $args[0] -Count 1 -ErrorAction SilentlyContinue
    $TESTCON = $TESTCON.IPV4Address | foreach { $_.IPAddressToString }
    return $TESTCON
}


#Conver the IP to a hostname through DNS
function ip2host
{
    return [system.net.dns]::GetHostByAddress($args[0]).hostname
}


#Lets the user know that the script is done
function NoticeWindow
{
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Completed. See Output file",0,"Done",0x1)
    $wshell
}


#layout of CSV is converted for the input type Hostname.
function UsingHost
{
        $OutputString = $SYS
        $OutputString += ","
        $OutputString += host2ip $SYS
        $OutputString += ","
        $OutputString += netstate $SYS
        $OutputString | out-file hostoutput.csv -append -Encoding ascii
}


#layout of CSV is converted for the input type IP address.
function UsingIPaddress
{
        #Convert to Hostname from IP first!
        $OutputString = ip2host $SYS
        $OutputString += ","
        $OutputString += $SYS
        $OutputString += ","
        $OutputString += netstate $SYS
        $OutputString | out-file hostoutput.csv -append -Encoding ascii
}


#############################################################################################
################################## CALLING THE FUNCTIONS ####################################
#############################################################################################


"Hostname,IP address, Network State" | out-file hostoutput.csv -append -Encoding ascii
$INPUT_FILE = Get-Content input.txt
write-host "number of systems: " -NoNewline
$INPUT_FILE.Count
Foreach ($SYS IN $INPUT_FILE)
{
    if($SYS -match '\d*\.\d*\.\d*\.\d*' -eq $true)
    {
        UsingIPaddress $SYS
    }
    else
    {
        UsingHost $SYS
    }
} 
NoticeWindow