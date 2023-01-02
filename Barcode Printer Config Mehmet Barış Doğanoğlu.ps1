Function Send-TCPMessage {
    Param (
            [Parameter(Mandatory=$true, Position=0)]
            [ValidateNotNullOrEmpty()]
            [string]
            $EndPoint
        ,
            [Parameter(Mandatory=$true, Position=1)]
            [int]
            $Port
        ,
            [Parameter(Mandatory=$true, Position=2)]
            [string]
            $Message
    )
    Process {
        # Setup connection
        $IP = [System.Net.Dns]::GetHostAddresses($EndPoint)
        $Address = [System.Net.IPAddress]::Parse($IP)
        $Socket = New-Object System.Net.Sockets.TCPClient($Address,$Port)
        # Setup stream wrtier
        $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        # Write message to stream
        $Message | % {
            $Writer.WriteLine($_)
            $Writer.Flush()
        }
        # Close connection and stream
        $Stream.Close()
        $Socket.Close()
    }
}


$inch2cm = 2.54 # 1 inch equals 2.54 cm.
$dpi = 203.2 # Zebra ZD421 with 203 dpi barcode printers are used in Ankara Ceviz WH.
$labelwidth = Read-Host "Enter the width of label in cm" # User enters label width in cm.
$labellength = Read-Host "Enter the length of label in cm" # User enters label length in cm.
$network_block = "10.215." # Ankara Ceviz WH Network block.
$client_block = Read-Host "Complete the IP Address 10.215 block." # User enters the rest of the IP Adress (Client block).
$ip = $network_block +$client_block # Combines network block with client block.

Write-Host "**********TRYING TO CONNECT THE MACHINE**********"

if((Test-NetConnection -ComputerName $ip | Select-Object pingsucceeded)){ #Checks the device if it is reachable. If it is, the if block will be executed.


    Write-Host "----------CONNECTION ESTABLISHED----------"

    $labelwidth_indots = ($labelwidth / $inch2cm) * $dpi # Calculates the value of label width in dots.
    $labellength_indots = ($labellength / $inch2cm) * $dpi # Calculates the value of label length in dots.
    $labelwidth_indots = $labelwidth_indots.ToString() # It turns integer to string.
    $labellength_indots = $labellength_indots.ToString() # It turns integer to string.
    $lengthcommand = "^XA" + "^LL" + "$labellength_indots" + "^XZ" # Prepares Label length command.
    $widthcommand = "^XA" + "^PW" + "$labelwidth_indots" + "^XZ" # Prepares Label width command.


    #$conf0 = '^XA^JUF^XZ' #Factory Reset '! U1 do "device.restore_defaults" ""' # It sets the device configuration to Factory default 
    $conf1 = '! U1 setvar "device.command_override.add" "{0}"' -f $lengthcommand # Label length command in ZPLII
    $conf2 = '! U1 setvar "device.command_override.add" "{0}"' -f $widthcommand # Label width command in ZPLII
    $conf3='^XA~JC^XZ' # Label Calibration
    $conf4='! U1 setvar "device.command_override.add" "~SD20"' # Sets the darkness of printing (0-30)
    $conf5='! U1 setvar "device.command_override.add" "^PO"' # Label orientation
    $conf6='! U1 setvar "device.command_override.add" "^PR6,6"'     #Print speed
    $conf7='! U1 setvar "device.command_override.add" "^MMP"'    #Peel-off configuration
    $conf8='! U1 setvar "device.command_override.add" "^MPE"' # Enables all modes of printer
    $conf9= '! U1 setvar "ip.snmp.enable" "off"'
    $conf10=‘! U1 setvar “device.reset_button_enable” “off”’
    $conf11=‘! U1 setvar “ip.snmp.get_community_name” “system3"’
    $conf12=‘! U1 setvar “ip.snmp.set_community_name” “system3"’
    $conf13=‘! U1 setvar “ip.snmp.trap_community_name” “system3"’
    $conf14='! U1 setvar "media.draft_mode" "off"'
    $conf15='! U1 setvar "power.energy_star.enable" "on"' # Sets Power Saving Mode OFF
    $conf16='! U1 setvar "bluetooth.enable" "on"' # Sets Bluetooth Connection OFF
    $conf17='! U1 do "device.reset" ""' # Reboots the printer.


    #Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf0
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf1
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf2
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf4
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf5
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf6
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf7
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf8
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf9
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf10
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf11
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf12
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf13
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf14
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf15
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf16
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf17

    Start-Sleep -Seconds 25
    Send-TCPMessage -Port 9100 -Endpoint $ip -message $conf3


    Write-Host "##########CONFIGURATION IS DONE##########"


}

else{Write-Host "!!!!!!!!!!TRANSMISSION FAILED!!!!!!!!!!"}
