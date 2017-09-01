#Add the custom lists (The lists should be in an accessible place so that the script can call it)
param (  
    $SiteUrl = $(throw "Required parameter -SiteUrl missing"),
    [xml]$ListDataXml = $(throw "Required parameter -ListDataXml missing")
)

$web = Get-SPWeb $SiteUrl

# get prerequisites
$listUrl = $ListDataXml.Elements.ListInstance.Url
if (-not($listUrl)) {  
    throw "List URL missing in <ListInstance Url='...'/>"
}

$list = $web.GetList($listUrl)
Write-Host "Importing data for list '$($list.Title)'..."

$i = 0
foreach ($row in $ListDataXml.Elements.ListInstance.Data.Rows.Row) {  
    $i++
    Write-Host "`tProcessing item $($i)..."

    $item = $list.AddItem()

    foreach ($field in $row.Field) {
        Write-Host "`t`tField $($field.Name)..." -NoNewLine

        $listField = $list.Fields.GetFieldByInternalName($field.Name)

        if ($listField.Type -eq "DateTime") {
            $item[$field.Name] = [DateTime]::Parse($field.InnerText, $web.Locale, "AssumeUniversal")
        }
        else {
            $item[$field.Name] = $field.InnerText
        }

        Write-Host "DONE" -ForegroundColor Green
    }

    $item.Update()
}

Write-Host "`Data import completed" -ForegroundColor Green  