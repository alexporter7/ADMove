#===========================================================
#===                        AD Move                      ===
#===========================================================
# Author: Alex Porter
# Description: Moves computers by batch into specific
#              defined AD groups, which can be added
#              and documented below. Manual config settings
#              are commented and can be changed based on
#              your situational needs
#===========================================================
#===                        AD Move                      ===
#===========================================================
# Exit Code 0 - No Error
# Exit Code 1 - No Unprocessed Files in directory
# Exit Code 2 - Moved computers and Scope count not equal
# Exit Code 3 - Feature not Implemented
#===========================================================
#===              Computer Name File (WIP)               ===
#===========================================================
# The first line must contain "name" as that is how
# powershell imports CSV files. automatic prepend will
# eventually be added
#===========================================================
#name
#computername
#computername
#computername
#===========================================================
#===                    ToDo                             ===
#===========================================================
# Check for duplicates
# Dont count moves if computer ends up in same OU
# Add wildcard location select && confirmation
# Add Location from file
# Improve before and after to check for list
# Add automatic name csv implementation at head of file
#===========================================================

#$ComputerName = Read-Host -Prompt "[Service Tag]"
#$ComputerName = @("DTCBC9W3Y2","DTCBCJR3Y2","DTCBCKR3Y2","DTCBCJT3Y2","DTCBCGV3Y2","DTC5GQ9FX2","DTCBCGY3Y2","DTCBC9T3Y2","DTCBCKT3Y2","DTCBCDT3Y2","DTCBCFV3Y2","DTCBC9R3Y2","DTCBC9X3Y2","DTCBCBV3Y2","DTCBCNT3Y2","DTCBCHX3Y2","DTCBCJX3Y2","DTCBCHR3Y2","DTCBC8R3Y2","DTCBCKW3Y2","DTC5GRCFX2","DTCBCFX3Y2","DTCBCMV3Y2","DTC5GRCFX2","DTC5GR9FX2","DTCBCCV3Y2","DTCBCJW3Y2","DTCBCRS3Y2","DTCBCLS3Y2","DTCBCCR3Y2","DTC5GV7FX2","DTCBCQW3Y2","DTCBCJS3Y2","DTCBC8T3Y2")

$CWD = Get-Location #current working directory
$Computer_List_Path = "$($CWD)\computer_list.txt" #will be removed
$Date_Info = Get-Date -UFormat "%m_%d_%Y %H_%M_%S"; #log the date
$Log_File_Name = "$($Date_Info)_ADMoveLog.txt" #name of the log file
$Prefix = "DTC" #what the prefix should be

#===========================================================
#===               Manual Config Options                 ===
#===========================================================
$Change_Description = $false #change desc in ad
$Use_Manual_File = $false #check unprocessed dir or use manual file
$Use_Manual_Location = $true #use manual location
#===========================================================

$Directory_List = @("Logs", "Unprocessed", "Processed") #list of required directories
$Unprocessed_File_Index = 0 #set to zero but it wont be used unless there are files in which case it will be set to whatever the user chooses

#====================================================================
#===          Use manually defined values for testing             ===
#====================================================================
#===                    Location List                             ===
#====================================================================
# 0 - NAME OR DESCRIPTION FOR INDEX 0
# 1 - NAME OR DESCRIPTION FOR INDEX 1
# 2 - NAME OR DESCRIPTION FOR INDEX 2
# 3 - NAME OR DESCRIPTION FOR INDEX 3
# 4 - NAME OR DESCRIPTION FOR INDEX 4
#=====================================================================
$Location_List = @("DistinguishedName goes here",
                    "DistinguishedName goes here",
                    "DistinguishedName goes here",
                    "DistinguishedName goes here",
                    "DistinguishedName goes here")

#Index of the array you want to place the active directory machines into
$Location = $Location_List[0] #Location you are trying to place machines into

if ($Use_Manual_File -eq $true) {
  $Computer_Name = Import-CSV "$CWD\Unprocessed\NAME OF FILE HERE" #manual file option
} else {
  $Computer_Name = ""
}
#====================================================================

Function ExitScript($ExitCode) {

    Log("Exited with code [$ExitCode]")
    Read-Host -Prompt "[Press Enter to Exit]"
    exit

}

Function CheckPrefix($Computer) { #Check if Prefixes exist, append DTC if not

    if ($Computer.name -notlike "$($Prefix)*") { #use set prefix in top of code

        Log("No Prefix Detected for [$($Computer.name)] changed to [$($Prefix)$($Computer.name)]")
        return "$($Prefix)$($Computer.name)"

    } else {

        return $Computer.name #if it already has the prefix just return whatever it is

    }

}

Function CleanInput($Computer) {

  $CleanName = $Computer.name
  return $CleanName.trim()

}

# Function GetLocationFromFile($FilePath) {
#     #todo
# }

Function GetLocationFromWildcard($search) {

    $Location_List_Temp = @($Location)
    $Location_Results = Get-ADOrganizationalUnit -Filter {Name -like "*$search*"}

    ForEach ($r in $Location_Results) {
        $Location_List_Temp.Add($r.DistinguishedName)
    }

    return $Location_List_Temp

}

Function GetLocation {

    if ($Use_Manual_Location) {

        return $Location

    } else {

        #ToDo
        Log("Location From File Not Implemented")
        ExitScript(3)

    }

}

Function GetComputerName {

    if ($Use_Manual_File) {

        return $Computer_Name #return the global variable which should just be the same as it is manually set

    } else {

        $File_Index = Read-Host -Prompt "`n[Please Select File Index]"
        $Unprocessed_File_Index = $File_Index #set the global variable so it can be referenced later

        Log("Selecting File Index [$File_Index] corresponding to [$($Unprocessed_File_List[$File_Index].Name)]") #log all info

        return Import-CSV "$CWD\Unprocessed\$($Unprocessed_File_List[$File_Index].Name)" #take the name that is in the directory array and import the file

    }

}

Function CheckDirectoryList {

    ForEach ($path in $Directory_List) { #run through a for each list that is defined at the top, checks if each directory is present
        if ([System.IO.Directory]::Exists("$CWD\$path\")) {

            Log("Found [$path] Directory")
            Write-Host "Found [$path] Directory"

        } else { #if its not there create the directory

            New-Item -Path "$CWD\" -Name $path -ItemType "directory" | Out-Null
            Log("[$path] Directory has been created at [$CWD\$path]")
            Write-Host "Created [$path] Directory"

        }
    }

}

Function CheckUnprocessedFiles {

    if ($Unprocessed_File_List.Length -ne 0) { #if there are files present, print the tree out

        Write-Host "`n=== Files in Directory ==="
        $c = 0

        ForEach ($i in $Unprocessed_File_List) {

            Write-Host "[$c] $i"
            Log("Found [$c] $i in Unprocessed Directory")
            $c = $c + 1

        }

        Write-Host "" #Blank line

    } else { #if there are no files to import, then just exit with code 1

        Write-Host "`nNo Unprocessed Files in Directory"
        Log("No Unprocessed Files in Directory")

        ExitScript(1) #exit with error code 1

    }

}

Function MoveUnprocessedFile($name) { #after the script is run move the unprocessed file over to processed

    Copy-Item "$CWD\Unprocessed\$name" -Destination "$CWD\Processed\$name_$Date_Info" #to make sure everything runs smoothly copy it over then remove it in the original directory

    Write-Host "Copied [$name] to Processed directory"
    Log("Copied [$name] to Processed directory")

    Remove-Item "$CWD\Unprocessed\$name" #remove from unprocessed directory

    Write-Host "Removed [$name] from Unprocessed Directory"
    Log("Removed [$name] from Unprocessed Directory")

}

Function Log($text) { #simple logging function used in a couple scripts, timestamps each statement and is appended to the appropriate log file

    $dateInfo = Get-Date -UFormat "%m-%d-%Y %H:%M:%S"
    "$dateInfo | $text" | Out-File -Append "$CWD\Logs\$Log_File_Name" #log whatever text is passed through function, log file is a variable so it can be changed


}

Function MoveComputer($Computer) {

    $DistinguishedName = (get-ADComputer $Computer.name).distinguishedname #Get the current distinguished name

    #Before Move

    Write-Host $DistinguishedName #write to the screen
    Log("From $DistinguishedName")

    Move-ADObject $DistinguishedName -TargetPath $Location #move the machine

    #After Move

    $DistinguishedName2 = (get-ADComputer $Computer.name).distinguishedname #get the new distinguished name

    Write-Host $DistinguishedName2 #print the new one to the screen
    Log("To $DistinguishedName2")

    if ($Change_Description -eq $true) { #if changing the descriptions is necessary checks if option is enabled

        Set-ADComputer -Identity $Computer.name -Description $Computer.description
        Write-Host "Changed [$($Computer.Name)] Description to [$($Computer.Description)]"
        Log("Changed [$($Computer.Name)] Description to [$($Computer.Description)]")

    }

    Write-Host "" #print a blank line, mainly for formatting reasons

}

Function GetADScopeCount { #used before and after the move to test if the amount of computers moved matches the differnce in the scope

    $Computer_Count = 0 #Initiate count variable

    Get-ADComputer -Filter {Name -like "$($Prefix)*"} -SearchBase $Location | % {$Computer_Count++}
    return $Computer_Count

    #==========================
    #===      Old Way       ===
    #==========================
    # Get-ADComputer -Filter {Name -like "DTC*"} -Properties Name,CanonicalName | Where-Object {$_.CanonicalName -like "*$($Scope)*"} | % {$Computer_Count = $Computer_Count + 1} #foreach shortcut and count
    # return $Computer_Count
    #==========================

}

Write-Host "" #Blank Line
#====================================================================================================
#===                    Checks for required directories && Unprocessed Files                      ===
#====================================================================================================

CheckDirectoryList #calls Function
$Unprocessed_File_List = Get-ChildItem "$CWD\Unprocessed" #Gets all of the unprocessed files
CheckUnprocessedFiles #calls Function

#====================================================================================================
#===                    Checks for Description, Manual File, and Location                         ===
#====================================================================================================

if ($Change_Description) { #alert user before continuing

    Write-Host "Change Description set to [True]"
    Log("Change Description set to [True]")

} else {

    Write-Host "Change Description set to [False]"
    Log("Change Description set to [False]")

}

if ($Use_Manual_Location) { #alert user before continuing

    Write-Host "Use Manual Location set to [True]"
    Log("Use Manual Location set to [True]")

} else {

    Write-Host "Use Manual Location set to [False]"
    Log("Use Manual Location set to [False]")

}

if ($Use_Manual_File) { #alert user before continuing

    Write-Host "Use Manual File set to [True]"
    Log("Use Manual File set to [True]")

} else {

    Write-Host "Use Manual File set to [False]"
    Log("Use Manual File set to [False]")

}

Write-Host "Prefix set to [$Prefix]"
Log("Prefix set to [$Prefix]")

#====================================================================================================
#===                                Starts Main Part of the Script                                ===
#====================================================================================================

Write-Host "Starting ADMove Script"
Log("Starting ADMove Script")

$count = 0

$AD_Count_Before = GetADScopeCount($Scope) # how many computers were in scope previously
Log("Current Computers in [$Scope] are [$AD_Count_Before]")

$Computer_Name = GetComputerName #Gets computer name
$Location = GetLocation

#Write-Host $($Computer_Name.name)
#Write-Host $($Computer_Name.length)
# Write-Host $Location

ForEach ($c in $Computer_Name) {

    $c.name = CheckPrefix($c) #check if prefix is present, adds it in automatically if it is not
    $c.name = CleanInput($c) #check if spaces are present
    MoveComputer($c)
    $count = $count + 1

}

$AD_Count = GetADScopeCount($Scope) #Get computers actually in ad scope
$AD_Count = $AD_Count - $AD_Count_Before

Write-Host "Found [$AD_Count] Computers in defined scope"
Log("Found [$AD_Count] Computers in defined scope")

Write-Host "Moved [$count] Computers"
Log("Moved [$count] Computers")

if ($AD_Count -ne $count) {

    Write-Host "AD Count [$AD_Count] | Moved [$count]"
    Write-Host "Values are not equal"

    Log("AD Count [$AD_Count] | Moved [$count]")
    Log("Values are not equal")

    #add in override to move file into processed directory

    ExitScript(2)

}

if ($Use_Manual_File -eq $false) {

    Write-Host "Moving [$($Unprocessed_File_List[$Unprocessed_File_Index].name)] to Processed Directory"
    Log("Moving [$($Unprocessed_File_List[$Unprocessed_File_Index].name)] to Processed Directory")

    MoveUnprocessedFile($Unprocessed_File_List[$Unprocessed_File_Index].name)

}

ExitScript(0) #exit code with no errors

#====================================================================================================
#===                                       Old Detection Method                                   ===
#====================================================================================================
# if ([System.IO.File]::Exists($Computer_List_Path)) {

#     $Computer_List = Import-CSV $Computer_List_Path

#     Write-Host "Computer List File FOUND with [$($Computer_List.Length)] computers"
#     Log("Computer List File FOUND with [$($Computer_List.Length)] computers")

#     $Response = Read-Host "Continue [y/n]"

#     if ($Response -eq "y" -or $Response -eq "yes") {

#     } else {

#         ExitScript(0)

#     }


# } else {

#     Write-Host "computer_list.txt NOT FOUND"
#     Read-Host -Prompt "[Press ENTER to exit]"

# }

#====================================================================================================
