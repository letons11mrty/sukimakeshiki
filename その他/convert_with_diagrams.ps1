# Mermaid図付き要件定義書をWordファイルに変換するスクリプト

$mdFile = "要件定義書_図解付き.md"
$outputDir = "diagrams"
$outputMd = "要件定義書_図解付き_画像版.md"
$outputDocx = "要件定義書_図解付き_完全版.docx"

# 画像ディレクトリを作成
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Markdownファイルを読み込む
$content = Get-Content $mdFile -Raw -Encoding UTF8

# Mermaidコードブロックを抽出して画像化
$mermaidBlocks = [regex]::Matches($content, '```mermaid\r?\n(.*?)\r?\n```', [System.Text.RegularExpressions.RegexOptions]::Singleline)

$counter = 1
foreach ($match in $mermaidBlocks) {
    $mermaidCode = $match.Groups[1].Value
    $mmdFile = "$outputDir\diagram_$counter.mmd"
    $pngFile = "$outputDir\diagram_$counter.png"
    
    # Mermaidコードをファイルに保存
    $mermaidCode | Out-File -FilePath $mmdFile -Encoding UTF8
    
    # 画像に変換
    Write-Host "図 $counter を画像化しています..."
    & mmdc -i $mmdFile -o $pngFile -b transparent
    
    # Markdownの該当部分を画像に置換
    if (Test-Path $pngFile) {
        $imageMarkdown = "`n![図$counter]($pngFile)`n"
        $content = $content -replace [regex]::Escape($match.Value), $imageMarkdown
    }
    
    $counter++
}

# 新しいMarkdownファイルを保存
$content | Out-File -FilePath $outputMd -Encoding UTF8

Write-Host "`n画像版Markdownファイルを作成しました: $outputMd"

# Wordファイルに変換
Write-Host "`nWordファイルに変換しています..."
& pandoc $outputMd -o $outputDocx

if (Test-Path $outputDocx) {
    Write-Host "`n完成！Wordファイルを作成しました: $outputDocx" -ForegroundColor Green
    Write-Host "すべての図が画像として含まれています。" -ForegroundColor Green
} else {
    Write-Host "`nエラー: Wordファイルの作成に失敗しました。" -ForegroundColor Red
}
