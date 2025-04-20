# Automatically get the first active network adapter
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

if ($null -eq $adapter) {
    Write-Host "No active network adapter found. Exiting script."
    exit
} else {
    Write-Host "Found active network adapter: $($adapter.Name)"
}

# Define the IP addresses to be excluded from the results (your own IPs)
$excludeIPs = @("192.168.1.2", "192.168.0.2", "192.168.168.2")

# Define the IP range to scan
$range = "192.168.1.0/24"

# Run the Nmap scan with exclusions and minimal output
Write-Host "Running Nmap scan for range: $range"

# Initialize the Nmap results string
$nmapResults = ""

# Run Nmap scan for each of the IP ranges and collect live hosts' IPs
foreach ($range in @("192.168.1.0/24", "192.168.0.0/24", "192.168.168.0/24")) {
    Write-Host "Scanning range: $range"
    
    # Run the Nmap scan with exclusions, minimal output (-sn for ping scan, -oG for grepable output)
    $scanResults = & nmap -sn $range --exclude $($excludeIPs -join ",") -oG - | Select-String -Pattern "Up" | ForEach-Object { 
        # Extract just the IP addresses of hosts that are "Up"
        $_.Line.Split(" ")[1]
    }

    # Add the scan results to the overall results string
    $nmapResults += $scanResults -join "`n" + "`n"
}

# Show the found live IPs (if any)
if ($nmapResults -eq "") {
    Write-Host "No hosts found."
} else {
    Write-Host "Live hosts found:"
    Write-Host $nmapResults

    # Display the Nmap results in a popup window (using Windows Forms)
    Add-Type -AssemblyName "System.Windows.Forms"
    [System.Windows.Forms.MessageBox]::Show($nmapResults, "Nmap Scan Results", [System.Windows.Forms.MessageBoxButtons]::OK)
}
