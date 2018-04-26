$source = "\\server\share"
$dest = "F:\new-share-path"
$date = (Get-Date -format "yyy-MM-dd-HH.mm")

#Do not use /MIR command if using Windows Server DeDupe
robocopy "$source" $dest /MIR /SEC /R:2 /W:2 /LOG:F:\Logs\$date.txt /np
