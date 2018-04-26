#------------------------------------------------------------------------------------------
# You can create subsequent OIDs for new schema classes and attributes by appending a .X to the OID where X may be any number that you choose.
# A common schema extension scheme generally uses the following structure:
# If your assigned OID was: 1.2.840.113556.1.8000.2554.999999
# then classes could be under: 1.2.840.113556.1.8000.2554.999999.1
# which makes the first class OID: 1.2.840.113556.1.8000.2554.999999.1.1
# the second class OID: 1.2.840.113556.1.8000.2554.999999.1.2 etc...
# Using this example attributes could be under: 1.2.840.113556.1.8000.2554.999999.2
# which makes the first attribute OID: 1.2.840.113556.1.8000.2554.999999.2.1
# the second attribute OID: 1.2.840.113556.1.8000.2554.999999.2.2 etc...
#------------------------------------------------------------------------------------------
$Prefix="1.2.840.113556.1.8000.2554"
$GUID=[System.Guid]::NewGuid().ToString()
$Parts=@()
$Parts+=[UInt64]::Parse($guid.SubString(0,4),"AllowHexSpecifier")
$Parts+=[UInt64]::Parse($guid.SubString(4,4),"AllowHexSpecifier")
$Parts+=[UInt64]::Parse($guid.SubString(9,4),"AllowHexSpecifier")
$Parts+=[UInt64]::Parse($guid.SubString(14,4),"AllowHexSpecifier")
$Parts+=[UInt64]::Parse($guid.SubString(19,4),"AllowHexSpecifier")
$Parts+=[UInt64]::Parse($guid.SubString(24,6),"AllowHexSpecifier")
$Parts+=[UInt64]::Parse($guid.SubString(30,6),"AllowHexSpecifier")
$OID=[String]::Format("{0}.{1}.{2}.{3}.{4}.{5}.{6}.{7}",$prefix,$Parts[0],$Parts[1],$Parts[2],$Parts[3],$Parts[4],$Parts[5],$Parts[6])
$oid
#------------------------------------------------------------------------------------------
