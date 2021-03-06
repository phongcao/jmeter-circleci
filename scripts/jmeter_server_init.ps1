# ------------------------------------------------------
# Setup jmeter
# ------------------------------------------------------

$downloadPath = "C:\Downloads"
If (!(test-path $downloadPath)) {
    New-Item -ItemType "directory" -Force -Path $downloadPath
}

$jrePath = "C:\Java"
If (!(test-path $jrePath)) {
    New-Item -ItemType "directory" -Force -Path $jrePath
}

$jmeterPath = "C:\JMeter"
If (!(test-path $jmeterPath)) {
    New-Item -ItemType "directory" -Force -Path $jmeterPath
}

# ------------------------------------------------------
# Install Java runtime
# ------------------------------------------------------

# Download jre
$jreURL = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245060_d3c52aa6bfa54d3ca74e617f18309292"
$jreFile = join-path -path $downloadPath -childpath jre.exe

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $jreURL -OutFile $jreFile

# Install jdk
& $jreFile /s INSTALLDIR=$jrePath
$env:Path += ";$jrePath\bin"

# ------------------------------------------------------
# Install JMeter
# ------------------------------------------------------

# Download jmeter
$jmeterURL = "https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.4.zip"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $jmeterURL -OutFile "$downloadPath\jmeter.zip"

# Install jmeter
Expand-Archive "$downloadPath\jmeter.zip" -DestinationPath "$jmeterPath"

# ------------------------------------------------------
# Disable firewall for private networks
# ------------------------------------------------------
Set-NetFirewallProfile -Profile Private, Public -Enabled False

# ------------------------------------------------------
# Start listening
# ------------------------------------------------------
& C:\JMeter\apache-jmeter-5.4\bin\jmeter-server.bat -J server.rmi.ssl.disable=true
