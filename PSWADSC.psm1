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
    [Ensure] $Ensure = [Ensure]::Present

    [DscProperty()]
    [Switch] $UseTestCertificate
    

    # Tests if the resource is in the desired state.
    [bool] Test()
    {        
        Try {
                if ($Ensure -eq [Ensure]::Present)
                { 
                    
                
                }
                else
                {


                }
                Elseif ($Ensure -eq [Ensure]::Absent)
                {
                    Ge

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
    }        
       
    # Gets the resource's current state.
    [PSWADSC] Get()
    {        
        $PSWA = Get-WindowsFeature -Name WindowsPowerShellWebAccess
        $AppPool = Get-Item -Path IIS:\AppPools\$($PSBoundParameters['WebApplicationName'])_Pool -ErrorAction SilentlyContinue
        $WebSite = Get-Item -Path IIS:\Sites\$($PSBoundParameters['WebSiteName']) -ErrorAction SilentlyContinue
        $SSLbindings = Get-ChildItem -Path IIS:\SslBindings -ErrorAction SilentlyContinue

        # NotConfigurable properties are set in the Get method.
        $this.PSWA       = $PSWA
        $this.AppPool    = $AppPool
        $this.WebSite    = $WebSite
        $this.SSLbindings= $SSLbindings
        $this
        # Return this instance or construct a new instance.
        return $this 
    }    
}