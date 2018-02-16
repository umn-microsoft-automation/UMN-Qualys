---
external help file: UMN-Qualys-help.xml
Module Name: UMN-Qualys
online version: 
schema: 2.0.0
---

# Set-QualysHostAssetTag

## SYNOPSIS
Set tag on a Host Asset

## SYNTAX

```
Set-QualysHostAssetTag [-hostID] <String> [-tagID] <String> [-qualysServer] <String>
 [-cookie] <WebRequestSession>
```

## DESCRIPTION
Set tag on a Host Asset

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -hostID
ID of a host

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tagID
ID of tag to apply to Host Asset

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -qualysServer
FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -cookie
Use Connect-Qualys to get session cookie

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

