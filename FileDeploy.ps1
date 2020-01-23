#Sleep -s 7200
# All Workstations and Servers #
#$workstations = Get-ADComputer -Filter * | Select -ExpandProperty Name

#$workstations = get-content -path "D:\Scripts\FileDeploy\workstationsTest.txt"
#$workstations = get-content -path "D:\Scripts\FileDeploy\workstations.txt"
#$workstations = get-content -path "D:\Scripts\FileDeploy\workstations2ndTry.txt"
$workstations = get-content -path "D:\Scripts\FileDeploy\workstationsPBIServers.txt"

#$workstations = Get-Content -path "D:\Scripts\ScriptRes\fileServerList.txt"
$numWorkstations = $workstations.length
$count = 0
Write-Host ""
Get-Date -UFormat %T


$status = ""
$startTime = Get-Date
$execPath = Split-Path $MyInvocation.MyCommand.Path
$failedLog = ""
$fromPath = "D:\Scripts\Files\"

##################################################
## VV May need updated for new distributions VV ##
$logFileName = "Log - LOGNAME"
$filenames = "FILENAME.txt"
$folderName = "FolderName" # Folder that files in fileNames will be copied to (filenames parent)
$rcpt = "Example@domain.com"
## ^^ May need updated for new distributions ^^ ##
##################################################

$failedLog = $failedLog + "START FAILED LOG,`n"

#"TEST1"

foreach($workstation in $workstations)
{
    #"TEST2"
    If(Test-Connection $workstation -Count 1 -Quiet){
        ##################################################
        ## VV May need updated for new distributions VV ##
        $shortPath = "\\$workstation\c$\"  # Folder that folderName resides in (filenames grandparent)
        ## ^^ May need updated for new distributions ^^ ##
        ##################################################
    
        $toPath = "$shortPath$folderName\"
        $startWKS = Get-Date

        Write-Host "Start Copy -`t $Workstation"
        "Start Copy - $Workstation" | Add-Content "$execPath\$logFileName" -Encoding Ascii
    
        ForEach($filename in $fileNames)
        {
            $startFile = Get-Date
            Write-Host ""
            "" | Add-Content "$execPath\$logFileName" -Encoding Ascii  

            Write-Host "Processing '$fileName'"
            "Processing '$fileName'" | Add-Content "$execPath\$logFileName" -Encoding Ascii  

            Write-Host ""
            "" | Add-Content "$execPath\$logFileName" -Encoding Ascii  

            Write-Host "Deleting old '$fileName' from '$workstation'..."
            "Deleting old '$filename' ..." | Add-Content "$execPath\$logFileName" -Encoding Ascii  

            If(Test-path $toPath\$filename)
            { 
                Remove-Item "$toPath\$filename" -Recurse #-ErrorAction SilentlyContinue
            }
            else
            {
                Write-Host "`t$fileName' does not exist."
                "`t$fileName' does not exist." | Add-Content "$execPath\$logFileName" -Encoding Ascii  

                If(-Not (Test-Path $toPath))
                {
                    Write-Host "`tDirectory '$folderName' does not exist. Creating directory..."
                    "`tDirectory '$folderName' does not exist. Creating directory..." | Add-Content "$execPath\$logFileName" -Encoding Ascii  

                    New-Item -Path $shortPath -Name $folderName -itemType "Directory" | Out-Null
                    If(Test-Path $toPath)
                    {
                        Write-Host "`tDirectory '$folderName' Created Successfully"
                        "`tDirectory '$folderName' Created Successfully" | Add-Content "$execPath\$logFileName" -Encoding Ascii  
                    }
                    else
                    {
                        Write-Host "`tDirectory '$folderName' Creation Failed"
                        "`tDirectory '$folderName' Creation Failed" | Add-Content "$execPath\$logFileName" -Encoding Ascii  
                    }
                }
            }
            #Write-Host ""
            #"" | Add-Content "$execPath\$logFileName" -Encoding Ascii
    
            Write-Host ""
            "" | Add-Content "$execPath\$logFileName" -Encoding Ascii  

            Write-Host "Copying new '$fileName' to '$workstation'..."
            "Copying new '$fileName' to '$workstation'..." | Add-Content "$execPath\$logFileName" -Encoding Ascii  
           
            Copy-Item $fromPath\$fileName $toPath\$fileName -Recurse #-ErrorAction SilentlyContinue

            If(Test-Path $toPath\$filename)
            {
                $newFileSize = (Get-Item $toPath\$fileName).Length
                $checkFileSize = (Get-Item $fromPath\$fileName).Length
        
                If($newFileSize -eq $checkFileSize)
                {
                    Write-Host "`tCopy '$fileName' Successful"
                    "`tCopy '$fileName' Successful" | Add-Content "$execPath\$logFileName" -Encoding Ascii        
                   
                    $status = "SUCCESS" 
                }
                else
                {
                    Write-Host "`tCopy '$fileName' Failed"
                    "`tCopy '$fileName' Failed" | Add-Content "$execPath\$logFileName" -Encoding Ascii

                    $status = "FAILED"        
                }
            }
            else
            {
                Write-Host "`tCopy '$fileName' Failed"
                "`tCopy '$fileName' Failed" | Add-Content "$execPath\$logFileName" -Encoding Ascii  
             
                $status = "FAILED"
            }
            #Write-Host ""
            #"" | Add-Content "$execPath\$logFileName" -Encoding Ascii
            $endFile = (Get-Date).AddSeconds(1)
            $timeFile = ($endFile - $startFile).toString()

            Write-Host ""
            "" | Add-Content "$execPath\$logFileName" -Encoding Ascii  

            Write-Host "Processing Time for '$fileName' : $timeFile" 
            "Processing Time for '$fileName' : $timeFile" | Add-Content "$execPath\$logFileName" -Encoding Ascii

            If($status -like "*FAILED*"){
                $failedLog = $failedLog + "$workstation - $fileName,"
            }

        }

        $endWKS = (Get-Date).AddSeconds(1)
        $timeWKS = ($endWKS - $startWKS).toString()
        $count = $count + 1

        #"$workstation $status" | Add-Content "$execPath\$logFileName" -Encoding Ascii 

        Write-Host ""
            "" | Add-Content "$execPath\$logFileName" -Encoding Ascii  

        Write-Host "End Copy -`t $workstation -`t $timeWKS"
        "End Copy -`t $workstation -`t $timeWKS" | Add-Content "$execPath\$logFileName" -Encoding Ascii

        Write-Host ""
        "" | Add-Content "$execPath\$logFileName" -Encoding Ascii

        Write-Host "$count / $numWorkstations endpoints completed."
        "$count / $numWorkstations" | Add-Content "$execPath\$logFileName" -Encoding Ascii

        Write-Host "_______________________________________"
        "_______________________________________" | Add-Content "$execPath\$logFileName" -Encoding Ascii    

        Write-host ""
        "" | Add-Content "$execPath\$logFileName" -Encoding Ascii
    } 
    else{
        Write-Host "$Workstation did not ping"
        "$Workstation did not ping" | Add-Content "$execPath\$logFileName" -Encoding Ascii

        Write-Host "_______________________________________"
        "_______________________________________" | Add-Content "$execPath\$logFileName" -Encoding Ascii    

        Write-Host ""
        "" | Add-Content "$execPath\$logFileName" -Encoding Ascii

        $failedLog = $failedLog + "$workstation - (PING)$fileName,"
    } 
}

$endTime = (Get-Date).AddSeconds(1)
$finalTime = ($endTime - $startTime).toString()
$failedLog = $failedLog + "`nEND FAILED LOG`n"

Write-Host "Deploy Completed in $finalTime"
"Deploy Completed in $finalTime" | Add-Content "$execPath\$logFileName" -Encoding Ascii

Write-Host ""
"" | Add-Content "$execPath\$logFileName" -Encoding Ascii

Write-Host $FailedLog
"$FailedLog" | Add-Content "$execPath\$logFileName" -Encoding Ascii

Write-Host ""

Write-Host "$toPath$filename"
"$toPath$filename" | Add-Content "$execPath\$logFileName" -Encoding Ascii

Write-Host ""

Send-MailMessage -From "FileCopy@domain.com" -Subject "FileCopy Log" -To $rcpt -Attachments "$execPath\$logFileName" -Body "FileDeploy Log Attached" -SMTPServer Exchange.domain.com

Get-Date -UFormat %T

#$pause = Read-Host "Press Any Key To End..."