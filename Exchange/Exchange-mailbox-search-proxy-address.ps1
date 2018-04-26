get-mailbox -ResultSize unlimited | where {$_.emailaddressses -contains "parts.orders@domain2.com"} | select name,emailaddresses

get-distributiongroup -ResultSize unlimited | where {$_.emailaddressses -contains "parts.orders@domain2.com"} | select name,emailaddresses

get-distributiongroup parts@domain2.com | select *
