function loopUpdates {
	$updates = Get-WUList
	ForEach ($update in $updates) {
        $kb = $update.KB
        $size = $update.Size
        $title = $update.Title
        echo "Installing $kb - $size - $title"
		Get-WUInstall -KBArticleID $kb -AcceptAll -Install -IgnoreReboot
        
	}
}

try {
	Import-Module PSWindowsUpdate
    loopUpdates
} catch {
	Install-Module PSWindowsUpdate
	Import-Module PSWindowsUpdate
    loopUpdates
}
