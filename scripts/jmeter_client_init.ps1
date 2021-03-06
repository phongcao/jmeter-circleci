# ------------------------------------------------------
# Parameters
# ------------------------------------------------------
param(
    [string]$arg1,
    [string]$arg2
)

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

# Download test plan
$testplanURL = "https://raw.githubusercontent.com/phongcao/jmeter-circleci/main/jmeter/sample.jmx"
Invoke-WebRequest $testplanURL -OutFile "C:\JMeter\sample.jmx"

# ------------------------------------------------------
# Disable firewall for private networks
# ------------------------------------------------------
Set-NetFirewallProfile -Profile Private, Public -Enabled False

# ------------------------------------------------------
# Start testing
# ------------------------------------------------------
$jmeterBin = "C:\JMeter\apache-jmeter-5.4\bin\jmeter.bat"
$jmeterTestPlan = "C:\JMeter\sample.jmx"
"`n" | & $jmeterBin -n -X -J server.rmi.ssl.disable=true -t $jmeterTestPlan -G target_hostname=$arg2 -R $arg1
