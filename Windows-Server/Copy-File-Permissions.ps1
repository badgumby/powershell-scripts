# This is not really a script, more of a helpful command
# I frequently use this after copying folders between servers

# Copy the folder from one server to another. Example D:\Share on SERVER1 to D:\Share on SERVER2
# Then issue the following commands

# Create 'dirACL' of current directory tree permissions
icacls D:\Share /save dirACL /T /C /Q

# Restore 'dirACL' of backed up directory tree permissions
icacls D:\ /restore dirACL /T /C /Q

# icacls /save dirACL (save command and filename)
# icacls /restore dirACL (restore command and filename)
# /T (recursive)
# /C (continue on error)
# /Q (no info on success)
