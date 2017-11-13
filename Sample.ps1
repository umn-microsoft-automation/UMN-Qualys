$qualysServer = 'qualysapi.qualys.com'
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer -assetTagging
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer 

$data = Get-QualysReportList -qualysServer $qualysServer -cookie $cookie
$data
$data | select ID,TITLE,TYPE

get-QualysReport -qualysServer $qualysServer -cookie $cookie -id 11111 -outFilePath C:\Users\you
Get-QualysAssetGrp -qualysServer $qualysServer -cookie $cookie

Get-QualysAssetGrp -qualysServer $qualysServer -cookie $cookie -id '111111'


