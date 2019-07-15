function Get-AutomateComputerPatchPolicy {
    [CmdletBinding()]
    param (
        # ComputerID of the devices(s) in question (max count 64)
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(1,64)]
        [Alias('id')]
        [int[]]
        $ComputerID
    )
    
    begin {
        if (! $global:CWAServer) {Write-Error '$global:CWAServer not present!'}

        #Build the URL to hit
        $rawUri = ($global:CWAServer + '/cwa/api/v1/computers/')

        $arrComputerID = [System.Collections.ArrayList]@()
    }
    
    process {
        Foreach ($id in $ComputerID) {
            [void]($arrComputerID.Add($id))
        }
    }# process {
    
    end {
        $arrComputerID | Invoke-Parallel {
            $Uri = ($rawUri + $_ + '/EffectivePatchingPolicy')

            $i = 0
            Do {
                # build the parameters
                $i++
                $Splat = @{
                    Uri = $Uri
                    Headers = $global:CWAToken
                    ContentType = "application/json"
                    Body = @{'page' = $i}
                    Method = 'Get'
                }

                # Make the request
                try {
                    Invoke-RestMethod @Splat
                }
                catch {
                    Write-Error "Failed to perform Invoke-RestMethod to Automate API with error $_.Exception.Message"
                }
            }# Do {
            While ($return.count -gt 0)
        }# $arrComputerID | Invoke-Parallel {
    }
}

