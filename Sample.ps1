$qualysServer = 'qualysapi.qualys.com'
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer -assetTagging
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer

$data = Get-QualysReportList -uri $uri -header $header -cookie $cookie
$data
$data | select ID,TITLE,TYPE

get-QualysReport -uri $uri -header $header -cookie $cookie -id 11111 -outFilePath C:\Users\you
Get-QualysAssetGrp -uri $uri -header $header -cookie $cookie

Get-QualysAssetGrp -uri $uri -header $header -cookie $cookie -id '111111'


