---
external help file: UMN-Qualys-help.xml
Module Name: UMN-Qualys
online version: 
schema: 2.0.0
---

# Get-QualysTag

## SYNOPSIS
Get Qualys Tag(s)

## SYNTAX

### ID
```
Get-QualysTag -tagID <String> -qualysServer <String> -cookie <WebRequestSession>
```

### Search
```
Get-QualysTag -searchTerm <String> [-operator <String>] -qualysServer <String> -cookie <WebRequestSession>
```

### filter
```
Get-QualysTag -filter <Hashtable> -qualysServer <String> -cookie <WebRequestSession>
```

## DESCRIPTION
Get Qualys Tag(s)

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -tagID
ID of a tag

```yaml
Type: String
Parameter Sets: ID
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -searchTerm
part of the name of tag that will be used in a "Contains" search

```yaml
Type: String
Parameter Sets: Search
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -operator
operator to apply to searchTerm, options are 'CONTAINS','EQUALS','NOT EQUALS'. 
NOTE 'EQUALS' IS case sensative!

```yaml
Type: String
Parameter Sets: Search
Aliases: 

Required: False
Position: Named
Default value: CONTAINS
Accept pipeline input: False
Accept wildcard characters: False
```

### -filter
The search section can take a lot of params, see the Qualys Documentation for details. 
us the filter PARAMETER to create your own custom search

```yaml
Type: Hashtable
Parameter Sets: filter
Aliases: 

Required: True
Position: Named
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
Position: Named
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

