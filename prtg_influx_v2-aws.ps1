# Influx Zugangsdaten
$InfluxDBServer = "https://XXX.eu-central-1.timestream-influxdb.amazonaws.com:8086" #hier einmal die Timestream URL einfügen. Kann auch die IP sein.
$InfluxBucket = "prtg" #Bucket Name frei wählbar natürlich
$InfluxToken = "XXX" #hier die Token einfügen.
$InfluxUrl = "$InfluxDBServer/api/v2/write?orgID=XXX&bucket=$InfluxBucket&precision=s" #hier die Org ID einfügen.

# PRTG
$PRTGUrl = 'https://XXX.XXX.XXX.XXX:1616/api/v2' #hier die PRTG URL einfügen.
$PRTGToken = (Invoke-RestMethod -Method 'POST' -Body '{"username": "XXX", "password": "XXX"}' ($PRTGUrl + '/session')).token #hier die PRTG Token username und password einfügen.
$PRTGHeaders = @{'Authorization' = 'Bearer ' + $PRTGToken }
    
function Escape-Influx {
    param ($value)

    if (! ($value -is [string])) {
        return $value
    }

    return ($value.replace(" ", "\ ")).replace(",", "\,")
}
$elemente = 0
function Channels-To-Influx {
    param ($channels)

    $InfluxData = ""
    
    foreach ($channel in $channels) { 
        if ([string]::IsNullOrEmpty($channel.last_measurement)) {
            # skip channels without messurement
            Continue
        }

        $name = Escape-Influx -value $channel.channel.name
        $id = $channel.channel.id.Split(".")[0]
        $value = Escape-Influx -value $channel.last_measurement.value
        $timestamp = Get-Date -Date ((Get-Date -Date ($channel.last_measurement.timestamp)).ToUniversalTime()) -UFormat %s;

        if ((Get-Date -UFormat %s) - $timestamp -ge 2592000) {
            # skip data older than 30d
            Continue
        }

        if ([string]::IsNullOrEmpty($value)) {
            # empty values to zero
            $value = 0
        }

        $InfluxData += "$id $name=$value $timestamp`n"

        

    }

    if ([string]::IsNullOrEmpty($InfluxData)) {
        return
    }

    try {
        # Datenpunkt an InfluxDB senden
        Invoke-RestMethod -Headers @{Authorization = ("Token $InfluxToken") } -Uri $InfluxUrl -Method Post -Body $InfluxData
       
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Failed to add entrypoint:" $InfluxData
        Write-Host "Error: " $errorMessage
    }
}




Write-Host "Fetch first 3000 entries"
$channels = Invoke-RestMethod -Method 'GET' -Headers $PRTGHeaders -Uri ($PRTGUrl + '/channels/data?limit=3000')
$elemente += $channels.length
Channels-To-Influx -channels $channels

Write-Host "Fetch second 3000 entries"
$channels = Invoke-RestMethod -Method 'GET' -Headers $PRTGHeaders -Uri ($PRTGUrl + '/channels/data?limit=3000&offset=3000')
$elemente += $channels.length
Channels-To-Influx -channels $channels

Write-Host "Fetch third 3000 entries"
$channels = Invoke-RestMethod -Method 'GET' -Headers $PRTGHeaders -Uri ($PRTGUrl + '/channels/data?limit=3000&offset=6000')
$elemente += $channels.length
Channels-To-Influx -channels $channels

Write-Host "Fetch fourth 3000 entries"
$channels = Invoke-RestMethod -Method 'GET' -Headers $PRTGHeaders -Uri ($PRTGUrl + '/channels/data?limit=3000&offset=9000')
$elemente += $channels.length
Channels-To-Influx -channels $channels

Write-Host "Fetch fifth 3000 entries"
$channels = Invoke-RestMethod -Method 'GET' -Headers $PRTGHeaders -Uri ($PRTGUrl + '/channels/data?limit=3000&offset=12000')
$elemente += $channels.length
Channels-To-Influx -channels $channels

Write-Host "Fetch sixth 3000 entries"
$channels = Invoke-RestMethod -Method 'GET' -Headers $PRTGHeaders -Uri ($PRTGUrl + '/channels/data?limit=3000&offset=15000')
$elemente += $channels.length
Channels-To-Influx -channels $channels

Write-Host "Fetch seventh 3000 entries"
$channels = Invoke-RestMethod -Method 'GET' -Headers $PRTGHeaders -Uri ($PRTGUrl + '/channels/data?limit=3000&offset=18000')
$elemente += $channels.length
Channels-To-Influx -channels $channels

Write-Host "Finished. Restart in 60 seconds`n"

    


Write-Host "<?xml version=`"1.0`" encoding=`"UTF-8`"?>
<prtg>"
Write-Host "<result><channel>Elemente</channel><float>1</float><value>$elemente</value>
<limitmode>1</limitmode>
<LimitMinError>1.5</LimitMinError>
<LimitErrorMsg></LimitErrorMsg>
</result>"



# Beende den PRTG-Output
Write-Host "</prtg>"