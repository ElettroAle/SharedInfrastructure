$externalIP = "20.23.162.229"
$customDomain = "elettroale.com"

$Records = @()
$Records += New-AzDnsRecordConfig -IPv4Address $externalIP
New-AzDnsRecordSet -Name "*" `
    -RecordType A `
    -ResourceGroupName $ResourceGroup `
    -ZoneName $customDomain `
    -TTL 3600 `
    -DnsRecords $Records