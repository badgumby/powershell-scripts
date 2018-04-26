get-mailbox user.name@domain.com | select MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled

set-mailbox user.name@domain.com -MessageCopyForSendOnBehalfEnabled $true -MessageCopyForSentAsEnabled $true
