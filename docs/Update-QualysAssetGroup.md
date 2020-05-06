---
external help file: UMN-Qualys-help.xml
Module Name: UMN-Qualys
online version:
schema: 2.0.0
---

# Update-QualysAssetGroup

## SYNOPSIS
Update Asset Group

## SYNTAX

```
Update-QualysAssetGroup [-action] <String> [-cookie] <WebRequestSession> [[-ip] <String>] [-groupID] <Int32>
 [-qualysServer] <String> [<CommonParameters>]
```

## DESCRIPTION
Add or remove specific IP address from Asset Group.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -action
Action to be performed.
Add or delete.

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

### -cookie
Use Connect-Qualys to get session cookie

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ip
IP address of entry to add/remove

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -groupID
Asset group ID number to modify

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: 0
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
