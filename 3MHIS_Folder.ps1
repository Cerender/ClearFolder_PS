<#------------------------------------------------------------------------------
    Jason McClary
    mcclarj@mail.amc.edu
    14 April 2016
    
    Description:
    Delete 3MHIS folders in user profiles
    
    Arguments:
    If blank script runs against local computer
    Multiple computer names can be passed as a list separated by spaces:
        ProfileFix.ps1 computer1 computer2 anotherComputer
    A text file with a list of computer names can also be passed
        ProfileFix.ps1 comp.txt
    
    Tasks:
    - get computer name if needed
    - delete folder
    
    Path to file:
    \\COMP_NAME\SYSTEM_DRIVE\Users\USERNAME\3MHIS

--------------------------------------------------------------------------------
                                CONSTANTS
------------------------------------------------------------------------------#>
set-variable hisPath -option Constant -value "\3MHIS\"



<#------------------------------------------------------------------------------
                                    MAIN
------------------------------------------------------------------------------#>

## Format arguments from none, list or text file 
IF (!$args){
    $compNames = $env:computername # Get the local computer name
} ELSE {
    $passFile = Test-Path $args

    IF ($passFile -eq $True) {
        $compNames = get-content $args
    } ELSE {
        $compNames = $args
    }
}

FOREACH ($compName in $compNames) {
    
    IF(Test-Connection -count 1 -quiet $compName){
        $driveLetter = Get-WMIObject -class Win32_OperatingSystem -Computername $compName | select-object SystemDrive
        $currFilePath = "\\$compName\$($driveLetter.SystemDrive[0])$\Users"
        
        ForEach ($folder in (Get-ChildItem $currFilePath)){
            IF ($folder.PSisContainer){
                $pathToDel = "$currFilePath\$folder$hisPath"
                IF (Test-Path $pathToDel) {                         # Check Path to delete
                    Remove-Item -Force -Path $pathToDel -Recurse
                    "$compName - $folder - Folder found and deleted"
                } ELSE {
                    "$compName - $folder - Folder Not Found"
                }
            }
        }

    } ELSE {
        "$compName - Unable to connect"
    }
}