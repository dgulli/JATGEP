# Active Directory Variables
$domainname = 'gcp.bearpug.io'
Try{
    Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
    Write-Host "AD CS Installed" -ForegroundColor Green
    }
Catch{
    Write-Warning -Message $("Failed to install Active Directory Certificate Services. Error: "+ $_.Exception.Message)
    Break;
    }

Try{
    Install-ADcsCertificationAuthority -CAType StandaloneRootCA –CACommonName $domainname –CADistinguishedNameSuffix “DC=notabank,DC=com” –CryptoProviderName “RSA#Microsoft Software Key Storage Provider” -KeyLength 2048 –HashAlgorithmName SHA1 –ValidityPeriod Years –ValidityPeriodUnits 3 –DatabaseDirectory “C:\windows\system32\certLog” –LogDirectory “c:\windows\system32\CertLog” –Force
}
Catch{
    Write-Warning -Message $("Failed to configure Active Directory Certificate Services. Error: "+ $_.Exception.Message)
    Break;
    }