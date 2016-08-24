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
    [string]$WebApplicationName

    # Mandatory indicates the property is required and DSC will guarantee it is set.
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    # NotConfigurable properties return additional information about the state of the resource.
    # For example, a Get() method might return the date a resource was last modified.
    # NOTE: These properties are only used by the Get() method and cannot be set in configuration.        
    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $InstallDate

    [DscProperty()]
    [Switch] $UseTestCertificate
    

    # Tests if the resource is in the desired state.
    [bool] Test()
    {        
        Try {
                if ($Ensure -eq [Ensure]::Present)
                { 
                    Install-PswaWebApplication $PSBoundParameters -whatif
                
                }
                else
                {


                }

            return $true 

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
        # NotConfigurable properties are set in the Get method.
        $this.P3 = something
        # Return this instance or construct a new instance.
        return $this 
    }    
}