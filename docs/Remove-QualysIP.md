---
external help file: UMN-Qualys-help.xml
Module Name: UMN-Qualys
online version: 
schema: 2.0.0
---

# Remove-QualysIP

## SYNOPSIS
Remove IP from a group by groupId

## SYNTAX

```
Remove-QualysIP [[-ip] <String>] [-groupID] <String> [-qualysServer] <String> [-cookie] <WebRequestSession>
```

## DESCRIPTION
Remove IP from a group by groupId

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ip
{{Fill ip Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -groupID
{{Fill groupID Description}}

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

