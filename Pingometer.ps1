
# define output style
function DrawGood { Write-Host - -ForegroundColor Green -BackgroundColor DarkGray -NoNewline }
function DrawTimeout { Write-Host X -ForegroundColor Yellow -BackgroundColor Red -NoNewline }
function DrawTestError { Write-Host '#' -ForegroundColor Black -BackgroundColor Yellow -NoNewline }

$main = {
    DoPinConsole  # comment to disable 'always on top'
    $params = GetPingParams 
    DrawLegend # comment to skip legend display
    DoTestLoop $params
}

###### functions

function DrawLegend {
    DrawGood
    Write-Host ' good'
    DrawTimeout
    Write-Host ' bad'
    DrawTestError 
    Write-Host ' test error'
}

function DoPinConsole {
    $signature = @’
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int X,
        int Y,
        int cx,
        int cy,
        uint uFlags);
‘@
    $type = Add-Type -MemberDefinition $signature -Name SetWindowPosition -Namespace SetWindowPos -Using System.Text -PassThru
    $handle = (Get-Process -id $Global:PID).MainWindowHandle
    $alwaysOnTop = New-Object -TypeName System.IntPtr -ArgumentList (-1) # create IntPtr for 2nd SetWindowPos param, -1=topmost
    $success = $type::SetWindowPos($handle, $alwaysOnTop, 0, 0, 0, 0, 0x0003)
    Write-Host "Pinned!"
}

function GetPingParams
{
    # choose target
    $gateway = (((Get-wmiObject Win32_networkAdapterConfiguration | ?{$_.IPEnabled}).DefaultIPGateway) | out-string).Trim()
    $target = if(($result = Read-Host "Enter IP [empty->default gateway]") -eq ''){$gateway}else{$result}
    if ($target -ne $gateway){ $timeout = 100 }else{
    Write-Host "Using Gateway...   " -NoNewline
    $timeout = 50
    }
    Write-Host Timeout=$timeout
    $filter = 'Address="{0}" and Timeout={1}' -f $target, $timeout
    $filter
}

function DoTestLoop {
    param($filter)

    $errorRepeats = -1  # One error is 0 repeats, 2 errors is 1 repeat (no errors -1)

    while($true)
    {
       Try
       {
            if((Get-WmiObject -Class Win32_PingStatus -Filter $filter -ErrorAction Stop |  Select-Object Address, ResponseTime, Timeout, StatusCode).StatusCode -eq 0)
            {
                DrawGood
                $errorRepeats = -1
            }
            else
            {
                DrawTimeout
                $errorRepeats = -1
            }
            Start-Sleep -Milliseconds 200
        }
        Catch
        {
            #sometimes wmi geeks out from the Get-WmiObject spam, eventually it will recover
            #try to keep the character display rate roughtly consistent while actually testing less until the error stops
            $errorRepeats++
            $multiplier =  1 + (3 * [math]::min($errorRepeats, 15))
            for ($count = $multiplier; $count -gt 0;$count--) { DrawTestError }
            start-sleep -Milliseconds ($multiplier * 250)  # 250 is the normal 200 sleep, plus a 50 fudge for "average" response tiems
        }
    }
}

######################
& $main  # run main code at top of script
######################