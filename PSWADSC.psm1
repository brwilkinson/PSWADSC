# Defines the values for the resource's Ensure property.
enum Ensure
{
    # The resource must be absent.    
    Absent
    # The resource must be present.    
    Present
}


# [DscResource()] indicates the class is a DSC resource.
[DscResource()]
class PSWADSC
{

    # A DSC resource must define at least one key property.
    [DscProperty(Key)]
    [string]$WebSiteName = 'Default Web Site'

    [DscProperty()]
    [string]$WebApplicationName = 'PSWA'

    # Mandatory indicates the property is required and DSC will guarantee it is set.
    [DscProperty()]
    [Ensure]$Ensure = [Ensure]::Present

    [DscProperty()]
    [Bool]$UseTestCertificate

    [DscProperty()]
    [String]$SSLThumbPrint

    [DscProperty(NotConfigurable)]
    [String]$ApplicationPoolName

    [DscProperty(NotConfigurable)]
    [bool]$WindowsPowerShellWebAccessInstalled
    

    # Tests if the resource is in the desired state.
    [bool] Test()
    {        
        Try {
            $Status = $this.Get()
            if ($This.Ensure -eq [Ensure]::Present)
            { 
                    
                Write-verbose "WindowsPowerShellWebAccessInstalled: $($Status.WindowsPowerShellWebAccessInstalled)"
                if ($Status.WindowsPowerShellWebAccessInstalled -and $Status.WebSiteName -and ($Status.WebSiteName -eq $this.WebSiteName) -and 
                    $Status.WebApplicationName -and ($Status.WebApplicationName -eq $this.WebApplicationName) -and ($Status.SSLThumbPrint -eq $this.SSLThumbPrint) -and
                    $Status.ApplicationPoolName -and ($Status.ApplicationPoolName -eq $this.ApplicationPoolName))
                {
                    return $True
                }
                else
                {
                    return $False
                }
            }
            Else
            {
                
                if ($Status.WindowsPowerShellWebAccessInstalled -or $Status.WebApplicationName -or $Status.ApplicationPoolName)
                {
                    return $False
                }
                else
                {
                    return $True
                }

            } 
        }#Try  
        Catch {
                $exception = $_
                Write-Verbose 'Error occurred'
                while ($exception.InnerException -ne $null)
                {
                        $exception = $exception.InnerException
                        Write-Verbose $exception.message
                }
            return $true                
          }#Catch
        
    } 

    # Sets the desired state of the resource.
    [void] Set()
    {
        $Status = $this.Get()
        if ($This.Ensure -eq [Ensure]::Present)
        {
            if (-not $Status.WindowsPowerShellWebAccessInstalled)
            {
                Install-WindowsFeature -Name WindowsPowerShellWebAccess
            }
            
            Install-PswaWebApplication -WebApplicationName $this.WebApplicationName -WebSiteName $this.WebSiteName -UseTestCertificate:$this.UseTestCertificate -ErrorAction SilentlyContinue
            
            if ((-not $this.UseTestCertificate) -and $this.SSLThumbPrint)
            {
                #Import-Module -Name WebAdministration -Verbose:$false
                
                #Setup the SSL binding
            }
              
        }
        Else
        {
            if ($Status.WebApplicationName)
            {
                $WebApplication = $Status.WebApplicationName.TrimEnd('_pool')
                Remove-WebApplication -Name $WebApplication -Site $Status.WebSiteName -ErrorAction SilentlyContinue
            }
            if ($Status.ApplicationPoolName)
            {
                Remove-WebAppPool -Name $Status.ApplicationPoolName -ErrorAction SilentlyContinue
            }
            if ($Status.WindowsPowerShellWebAccessInstalled)
            {
                Uninstall-WindowsFeature -Name WindowsPowerShellWebAccess  -ErrorAction SilentlyContinue
            }
        }    
             
    }        
       
    # Gets the resource's current state.
    [PSWADSC] Get()
    {        
        Import-Module -Name WebAdministration -Verbose:$false
        $PSWA        = Get-WindowsFeature -Name WindowsPowerShellWebAccess -ErrorAction SilentlyContinue
        $AppPool     = Get-Item -Path "IIS:\AppPools\$($this.WebApplicationName)_Pool" -ErrorAction SilentlyContinue
        $WebApp      = Get-WebApplication -Site $this.WebSiteName -Name $this.WebApplicationName
        $WebSite     = Get-Item -Path "IIS:\Sites\$($this.WebSiteName)" -ErrorAction SilentlyContinue
        $SSLbindings = Get-ChildItem -Path IIS:\SslBindings -ErrorAction SilentlyContinue | where Sites -eq $this.WebSiteName

        $this.WebSiteName                         = $WebSite.Name
        $this.WebApplicationName                  = $WebApp.ApplicationPool
        $this.ApplicationPoolName                 = $AppPool.Name
        $this.SSLThumbPrint                       = $SSLbindings.Thumbprint
        $this.WindowsPowerShellWebAccessInstalled = $PSWA.Installed

        # Return this instance or construct a new instance.
        return $this
    }    
}