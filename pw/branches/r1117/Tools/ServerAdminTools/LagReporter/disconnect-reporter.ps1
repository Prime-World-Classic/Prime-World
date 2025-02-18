# ---------------------------------------------------------------------------------------

function exec-sql ($sql) {
$sw = [System.Diagnostics.Stopwatch]::StartNew()
  Write-Host "$(get-date) executing query`n$sql`n"
  # коннект к серверу (подразумевает наличие pgpass.conf)
  $result = psql -h $dbhost -p $dbport -d $dbname -U $dbuser -c "SET client_min_messages TO WARNING; COPY ($sql) TO STDOUT CSV;"
  if (!$?) {
    Write-Host 'psql failed'
    return
  }
$sw.stop()
write-host "$(get-date) script executed in $($sw.elapsed)`n"
return $result
}

# ---------------------------------------------------------------------------------------

function insert-to-excel ($worksheet, $cell, $str) {
  Add-Type -Assembly PresentationCore
  [Windows.Clipboard]::SetText($str, [Windows.TextDataFormat]'Text')
  $worksheet.range($cell.Address()).pasteSpecial(-4104) | out-null # xlPasteAll = -4104
}

# ---------------------------------------------------------------------------------------

function add-chart ($worksheet, $xvalues, $values, $title, $top, $left) {  
  $chart = $worksheet.shapes.addChart().chart
  $chart.SetSourceData($values)
  $chart.SeriesCollection(1).XValues = $xvalues
  $chart.SeriesCollection(1).Values = $values
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlPie
  $chart.ChartStyle = 26
  $chart.ApplyDataLabels()
  $chart.SeriesCollection(1).DataLabels().ShowPercentage = $true
  $chart.SeriesCollection(1).DataLabels().ShowValue = $false
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = $title
  $chart.Parent.Top  = $top
  $chart.Parent.Left = $left
  $chart.Parent.Height  = 230
  $chart.Parent.Width = 330
}


# ---------------------------------------------------------------------------------------
# start ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------

$exectime = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "`n`nstarted disconnect-reporter"
$i = 0
$args |% { 
  write-host "args[$i] = '$_', $($_.gettype())"
  $i++
}

# соединение с БД
$dbhost = 'b489.SITE'
$dbport = 5432
$dbname = 'pw_analysis_oa'
$dbuser = 'postgres'


$type = $args[0]
try {
  if ($type -eq 'daily'){
    $dh1 = [int]$args[1];
    $dh2 = $dh1
    $date1 = [DateTime]::ParseExact($dh1,'yyyyMMdd',$null)
    $date2 = $date1.AddDays(1).AddSeconds(-1)
    $datesuffix = "$dh1"
  }
  elseif ($type -eq 'weekly') {
    $dh1 = [int]$args[1];
    $dh2 = [int]$args[2];
    $date1 = [DateTime]::ParseExact($dh1,'yyyyMMdd',$null)
    $date2 = [DateTime]::ParseExact($dh2,'yyyyMMdd',$null).AddDays(1).AddSeconds(-1)
    $datesuffix = "$dh1-to-$dh2"
  }
  else { 
  	write-host "undefined report type $type" 
  	exit 1 
  }
}
catch {
  write-host 'error while parsing parameters'
  exit 1
}


# Тестовый ключ 'noagg' отключает перестроение агрегатов
if ($args -notcontains 'noagg') {

  # Построение всех нужных агрегаций
  if ($type -eq 'daily') {
    exec-sql "select aggregate_event_disconnect($dh1)"
  }
  if ($type -eq 'weekly') {
    $d = $date1
    while ($d -lt $date2) {
      exec-sql "select aggregate_event_disconnect($($d.tostring('yyyyMMdd')))"
      $d = $d.AddDays(1)
    }
  }
}


# ---------------------------------------------------------------------------------------
# Формирование Excel файла


# создание COM объекта Excel

$xc=New-Object -ComObject "Excel.Application"
write 'started Excel.Application'
$wb=$xc.Workbooks.Add()
if ($type -eq 'weekly') {
  $wb.Worksheets.Add() | out-null
}

$wsg = $wb.Worksheets.item(1)
$wsd=$wb.Worksheets.item(2)
if ($type -eq 'daily') {
  $wsg.name = 'Всего (графики)'
  $wsd.name = 'Всего (данные)'
}
if ($type -eq 'weekly') {
  $wsg.name = '{0:dd.MM}-{1:dd.MM} (графики)' -f $date1, $date2
  $wsd.name = '{0:dd.MM}-{1:dd.MM} (данные)'  -f $date1, $date2
}

# Общее число сессий/игроков
$data = exec-sql "
  select count(distinct gs.id), count(distinct pc.player)
  from gamesession gs
    join sessiontoplayer stp on gs.id = stp.gamesession and gs.location = stp.location
    join playercharacter pc on pc.id = stp.playercharacter and pc.location = stp.location  
  where timehierarchyid between $dh1 and $dh2
    and gs.starttime between '$($date1.tostring('yyyy-MM-dd'))' and '$($date2.tostring('yyyy-MM-dd HH:mm:ss'))'
    and gs.sessiontype = 4"

$gstotal = $data.split(',')


# Общее число сессий/игроков c дисконнектами
$data = exec-sql "
  select
    count(distinct gsid), 
    count(distinct case when leaver then gsid else null end),
    count(distinct player),
    count(distinct case when leaver then player else null end)
  from event_disconnect_agg_report
  where datehierarchy between $dh1 and $dh2"

$gstotald = $data.split(',')
  

# общая информация
$data = exec-sql "
  select 
    coalesce(upper(gs.cluster), 'NOINFO'), 
    count(distinct gs.id), count(stp.id), count(distinct pc.player)
  from sessiontoplayer stp
    join gamesession gs on gs.id = stp.gamesession and gs.location = stp.location
    join playercharacter pc on pc.id = stp.playercharacter and pc.location = stp.location
  where gs.timehierarchyid between $dh1 and $dh2
    and gs.starttime between '$($date1.tostring('yyyy-MM-dd'))' and '$($date2.tostring('yyyy-MM-dd HH:mm:ss'))'
    and gs.sessiontype = 4
  group by 1
  order by 1"

$sess = @()
$data |% {
  $d = $_.split(',')
  $sess += ,@($d[0],[int]$d[1],[int]$d[2],[int]$d[3])
}


# информация по дисконнектам
$data = exec-sql "
  select
    coalesce(cluster,'NOINFO'),
    count(distinct gsid), 
    count(distinct case when leaver then gsid else null end),
    count(distinct stpid),
    count(distinct case when leaver then stpid else null end),
    count(distinct player),
    count(distinct case when leaver then player else null end),
    count(*),
    count(case when firstleaver then id else null end)    
  from event_disconnect_agg_report
  where datehierarchy between $dh1 and $dh2
  group by cluster"

$disc = @()
$data |% {
  $d = $_.split(',')
  $disc += ,@($d[0],[int]$d[1],[int]$d[2],[int]$d[3],[int]$d[4],[int]$d[5],[int]$d[6],[int]$d[7],[int]$d[8])
}


# Данные по типам
$enumd = @(  
  'Connecting',
  'Ready',
  'Active',
  'Away',
  'DisconnectedByClient',
  'DisconnectedByServer',
  'ConnectionTimedOut',
  'DisconnectedByCheatAttempt',
  'DisconnectedByClientIntentionally',
  'ConnectionTimedOutOnReconnect',
  'DisconnectedByAsync',
  'RefusedToReconnect')

$data = exec-sql "
  select
    coalesce(cluster,'NOINFO'),
    type,
    count(*)
  from event_disconnect_agg_report
  where datehierarchy between $dh1 and $dh2
  group by cluster, type"

$btype = @()
$data |% {
  $d = $_.split(',')
  $btype += ,@($d[0],$enumd[$d[1]],[int]$d[2])
}

# Агрегированные данные по типам
$data = exec-sql "
  select
    type,
    count(*), 
    count(distinct case when leaver then id else null end),
    count(distinct case when firstleaver then id else null end)
  from event_disconnect_agg_report
  where datehierarchy between $dh1 and $dh2
  group by type order by type"

$btypeagg = @()
$data |% {
  $d = $_.split(',')
  $btypeagg += ,@($enumd[$d[0]],[int]$d[1],[int]$d[2],[int]$d[3])
}


# Заполнение данных
$data = 
"`tTOTAL
Сессий всего`t$($gstotal[0])
Сессий с дисконнектами`t$($gstotald[0])`t=B3/B2
Сессий с ливерами`t$($gstotald[1])`t=B4/B2

Игроков (не уник.) всего`t$(($sess |% {$_[2]} | measure -sum).sum)
Игроков (не уник.) с дисконнектами`t$(($disc |% {$_[3]} | measure -sum).sum)`t=B7/B6
Игроков (не уник.) ливеров`t$(($disc |% {$_[4]} | measure -sum).sum)`t=B8/B6

Игроков (уник.) всего`t$($gstotal[1])
Игроков (уник.) с дисконнектами`t$($gstotald[2])`t=B11/B10
Игроков (уник.) ливеров`t$($gstotald[3])`t=B12/B10

Всего дисконнектов`t$(($disc |% {$_[7]} | measure -sum).sum)
Дисконнектов первых ливеров`t$(($disc |% {$_[8]} | measure -sum).sum)


Типы дисконнектов (по кластерам)`tTOTAL
"

$r = 19
$btypeagg |% {
  $data += "$($_[0])`t$($_[1])`t=$($wsd.cells.item($r,4).Address())/$($wsd.cells.item(14,4).Address())`n"
  $r++
}

insert-to-excel $wsd $wsd.cells.item(1,1) $data
$wsd.columns.item(1).columnwidth = 40
$wsd.cells.range('A2:A15').font.bold = $true
$wsd.rows.item(1).font.bold = $true
$wsd.rows.item(18).font.bold = $true
$wsd.cells.range($wsd.cells.item(1,2), $wsd.cells.item(15,3)).interior.color = 14610923
$wsd.cells.range($wsd.cells.item(18,2), $wsd.cells.item(18+$btypeagg.length,3)).interior.color = 14610923
$wsd.cells.range($wsd.cells.item(1,3), $wsd.cells.item(18+$btypeagg.length,3)).font.bold = $true
$wsd.cells.range($wsd.cells.item(1,3), $wsd.cells.item(18+$btypeagg.length,3)).numberformat = '0,0%'


$col = 4
$sess |% {
  $cluster = $_[0]
  if ($cluster -eq 'zzz') { $cluster = 'NOINFO' }
  
  $d = $disc |? { $_ -eq  $cluster}

  $data = 
"$cluster
$($_[1])
$($d[1])`t=$($wsd.cells.item(3,$col).Address())/$($wsd.cells.item(2,$col).Address())
$($d[2])`t=$($wsd.cells.item(4,$col).Address())/$($wsd.cells.item(2,$col).Address())

$($_[2])
$($d[3])`t=$($wsd.cells.item(7,$col).Address())/$($wsd.cells.item(6,$col).Address())
$($d[4])`t=$($wsd.cells.item(8,$col).Address())/$($wsd.cells.item(6,$col).Address())

$($_[3])
$($d[5])`t=$($wsd.cells.item(11,$col).Address())/$($wsd.cells.item(10,$col).Address())
$($d[6])`t=$($wsd.cells.item(12,$col).Address())/$($wsd.cells.item(10,$col).Address())

$($d[7])
$($d[8])


$cluster
"

  $r = 19
  $btypeagg |% {
    $t = $_[0]
    $cnt = $btype |? { $_[0] -eq $cluster -and $_[1] -eq $t } |% { $_[2] }
    if ($cnt -eq $null) { $cnt = 0 }
    $data += "$cnt`t=$($wsd.cells.item($r,$col).Address())/$($wsd.cells.item(14,$col).Address())`n"
    $r++
  }

  insert-to-excel $wsd $wsd.cells.item(1, $col) $data
  
  if ([int]($col/4)*4 -ne $col) {
    $wsd.cells.range($wsd.cells.item(1,$col), $wsd.cells.item(15,$col+1)).interior.color = 14610923
    $wsd.cells.range($wsd.cells.item(18,$col), $wsd.cells.item(18+$btypeagg.length,$col+1)).interior.color = 14610923
  }
  $wsd.cells.range($wsd.cells.item(1,$col+1), $wsd.cells.item(18+$btypeagg.length,$col+1)).font.bold = $true
  $wsd.cells.range($wsd.cells.item(1,$col+1), $wsd.cells.item(18+$btypeagg.length,$col+1)).numberformat = '0,0%'
  
  $col += 2
}

$row = $data.split("`n").length + 1
$rowbtypeagg = $row + 1

$data="Типы дисконнектов`tВсе`tЛиверы`tПервые ливеры`n"
$btypeagg |% {
  $data += "{0}`t{1}`t{2}`t{3}`n" -f $_[0], $_[1], $_[2], $_[3]
}
insert-to-excel $wsd $wsd.cells.item($row, 1) $data
$wsd.rows.item($row).font.bold = $true

$row += $data.split("`n").length + 1


# Клиентские дисконнекты
$enumc = @(
  'Unknown',
  'ClientLaunched',
  'ClientCrash',
  'LoginFailed',
  'Disconnect',
  'DisconnectCorruptData',
  'ConnectionFailed',
  'DisconnectInFR',
  'LoginFailedInFR')

$data = exec-sql "
  select
    coalesce(offtype,0),
    count(*),
    count(distinct case when leaver then id else null end),
    count(distinct case when firstleaver then id else null end)
  from event_disconnect_agg_report
  where datehierarchy between $dh1 and $dh2
    and type = 4
  group by 1 order by 1"

$dclient = @()
$data |% {
  $d = $_.split(',')
  $dclient += ,@($enumc[$d[0]],[int]$d[1],[int]$d[2],[int]$d[3])
}

$data = "Клиентские типы DisconnectedByClient`tВсе`tЛиверы`tПервые ливеры`n"
$dclient |% {
  $data += "{0}`t{1}`t{2}`t{3}`n" -f $_[0], $_[1], $_[2], $_[3]
}
insert-to-excel $wsd $wsd.cells.item($row, 1) $data
$wsd.rows.item($row).font.bold = $true
$rowdclient = $row + 1
$row += $data.split("`n").length + 1


# Результаты сессий

$enumt = @( # значения сдвинуты на +1
  'Undefined',
  'SyncResults',
  'NoResults',
  'NobodyCame',
  'AsyncResults',
  'Async',
  'Unknown')

$data = exec-sql "
  select sessionresult, count(*)
  from gamesession gs
  where timehierarchyid between $dh1 and $dh2
    and sessiontype = 4
  group by 1
  order by 1"

$sres = @()
$data |% {
  $d = $_.split(',')
  $sres += ,@($enumt[[int]$d[0]+1],[int]$d[1])
}

$data="Результаты сессий по типам`tКоличество`n"
$sres |% {
  $data += "{0}`t{1}`n" -f $_[0], $_[1]
}
insert-to-excel $wsd $wsd.cells.item($row, 1) $data
$wsd.rows.item($row).font.bold = $true

$row += $data.split("`n").length + 1
insert-to-excel $wsd $wsd.cells.item($row, 1) ''


# добавление чартов

$xcoord = 10
$datacol = 2
$xrange = $wsd.range("A19:A$(19+$btypeagg.length-1)")
$clusters = @('TOTAL')
$clusters += $sess |% { $_[0] }
$clusters |% {
  $cluster = $_
  if ($cluster -eq 'zzz') { $cluster = 'NOINFO' }
  
  $title = 'Все дисконнекты'
  if ($cluster -ne 'TOTAL') { $title += " $cluster" }
  
  $yrange = $wsd.range($wsd.cells.item(19,$datacol),$wsd.cells.item(19+$btypeagg.length-1,$datacol))
  add-chart $wsg $xrange $yrange $title 10 $xcoord
  $xcoord += 340
  $datacol += 2
}

$yrange = $wsd.range($wsd.cells.item($rowbtypeagg,3),$wsd.cells.item($rowbtypeagg+$btypeagg.length-1,3))
add-chart $wsg $xrange $yrange 'Дисконнекты ливеров' 250 10

$yrange = $wsd.range($wsd.cells.item($rowbtypeagg,4),$wsd.cells.item($rowbtypeagg+$btypeagg.length-1,4))
add-chart $wsg $xrange $yrange 'Дисконнекты первых ливеров' 250 350

$xrange = $wsd.range($wsd.cells.item($rowdclient,1),$wsd.cells.item($rowdclient+$dclient.length-1,1))
$yrange = $wsd.range($wsd.cells.item($rowdclient,2),$wsd.cells.item($rowdclient+$dclient.length-1,2))
add-chart $wsg $xrange $yrange 'Клиентские типы DisconnectedByClient' 250 690

# Cерверные дисконнекты по часам для ежедневного отчета

if ($type -eq 'daily') {  

  $data = exec-sql "
    select extract('hours' from timestamp) as hour, 
           count(*), 
           count(case when firstleaver then id else null end)
    from event_disconnect_agg_report
    where datehierarchy between $dh1 and $dh2 
    group by hour
    order by 1"

  $bhour = @()
  $data |% {
    $d = $_.split(',')
    $bhour += ,@([int]$d[0],[int]$d[1],[int]$d[2])
  }


  $wsh = $wb.Worksheets.item(3)
  $wsh.name = 'По часам'

  $data="Час`tВсего дисконнектов`tДисконнекты первых ливеров`n"
  0..23 |% {
    $h = $_
    $cnt = $bhour |? { $_[0] -eq $h }
    if ($cnt -eq $null) { $cnt = @(0,0,0) }
    $data += "$h`t$($cnt[1])`t$($cnt[2])`n"
  }
  
  insert-to-excel $wsh $wsh.cells.item(1,1) $data
  insert-to-excel $wsh $wsh.cells.item(27,1) '' # убираем выделение

  # график по часам
  $chart = $wsh.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlLine
  $chart.SetSourceData($wsh.cells.range('A2:B25'))
  $chart.SeriesCollection(1).Values = $wsh.cells.range($wsh.cells.item(2,2),$wsh.cells.item(25,2))
  $chart.SeriesCollection(1).Name = 'Всего'
  $chart.SeriesCollection(2).Values = $wsh.cells.range($wsh.cells.item(2,3),$wsh.cells.item(25,3))
  $chart.SeriesCollection(2).Name = 'Первых ливеров'
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = 'Дисконнекты по часам'
  $chart.parent.Top = 10
  $chart.parent.Left = 200
  $chart.parent.Height = 250
  $chart.parent.Width = 480

  # форматирование
  $wsh.columns.item(1).columnwidth = 5
  $wsh.columns.item(2).columnwidth = 10
  $wsh.columns.item(3).columnwidth = 10
  $wsh.rows.item(1).font.bold = $true
}


# графики по дням для еженедельного отчета 

if ($type -eq 'weekly') {

  $wsg = $wb.Worksheets.item(3)
  $wsd = $wb.Worksheets.item(4)
  $wsg.name = 'По дням (графики)'
  $wsd.name = 'По дням (данные)'
  
  $data = "Сессии`nВсего`tС дисконнектами`tС ливерами`t% с дисконнектами`t% с ливерами"
  insert-to-excel $wsd $wsd.cells.item(1,2) $data
  
  $data = "Дисконнекты`nВсего"
  $enumd[4..10] |% { $data = "$data`t$_" }
  insert-to-excel $wsd $wsd.cells.item(1,7) $data
  
  $data = "Дисконнекты первых ливеров`nВсего"
  $enumd[4..10] |% { $data = "$data`t$_" }
  insert-to-excel $wsd $wsd.cells.item(1,15) $data
  
  $data = "Клиентские типы DisconnectedByClient`nВсего"
  $enumc[0,2,4,7] |% { $data = "$data`t$_" }
  insert-to-excel $wsd $wsd.cells.item(1,23) $data  
  
  # Общее число сессий
  $data = exec-sql "
    select timehierarchyid, count(*)
    from gamesession gs
    where timehierarchyid between $dh1 and $dh2
      and sessiontype = 4
    group by 1
    order by 1"
    
  $gsweek = @()
  $data |% {
    $d = $_.split(',')
    $gsweek += ,@([int]$d[0],[int]$d[1])
  }
  
  # Сессии с дисконнектами
  $data = exec-sql "
    select
      datehierarchy,
      count(distinct gsid), 
      count(distinct case when leaver then gsid else null end)
    from event_disconnect_agg_report
    where datehierarchy between $dh1 and $dh2
    group by datehierarchy"

  $dweek = @()
  $data |% {
    $d = $_.split(',')
    $dweek += ,@($d[0],[int]$d[1],[int]$d[2])
  }
  
  # Дисконнекты по типам
  $data = exec-sql "
    select
      datehierarchy,
      type,
      count(*), 
      count(distinct case when firstleaver then id else null end)
    from event_disconnect_agg_report
    where datehierarchy between $dh1 and $dh2
    group by datehierarchy, type"

  $btypeweek = @()
  $data |% {
    $d = $_.split(',')
    $btypeweek += ,@($d[0],$d[1],$d[2],$d[3])
  }

  # Клиентские дисконнекты
  $data = exec-sql "
    select
      datehierarchy,
      coalesce(offtype,0),
      count(*)
    from event_disconnect_agg_report
    where datehierarchy between $dh1 and $dh2
      and type = 4
    group by 1,2"

  $dclientweek = @()
  $data |% {
    $d = $_.split(',')
    $dclientweek += ,@($d[0],$d[1],$d[2])
  }


  # Заполнение отчета
  $d = $date1
  $row = 3
  while ($d -le $date2) {

    $dh = [int]$d.tostring('yyyyMMdd')
    $data = $d.tostring('dd MMM')    
    
    # сессии
    $dw = $dweek |? { $_ -eq $dh }
    $data = "$data`t$($gsweek |? {$_[0] -eq $dh} |% {$_[1]})`t$($dw[1])`t$($dw[2])"

    $data = "$data`t=$($wsd.cells.item($row,3).Address())/$($wsd.cells.item($row,2).Address())"
    $data = "$data`t=$($wsd.cells.item($row,4).Address())/$($wsd.cells.item($row,2).Address())"
    
    # дисконнекты
    $data = "$data`t=СУММ($($wsd.cells.item($row,8).Address()):$($wsd.cells.item($row,14).Address()))"
    4..10 |% {
      $id = $_
      $cnt = $btypeweek |? { $_[0] -eq $dh -and $_[1] -eq $id } |% { $_[2] }
      if ($cnt -eq $null) { $cnt = 0 }
      $data = "$data`t$cnt"
    }
    
    # дисконнекты первых ливеров
    $data = "$data`t=СУММ($($wsd.cells.item($row,16).Address()):$($wsd.cells.item($row,22).Address()))"
    4..10 |% {
      $id = $_
      $cnt = $btypeweek |? { $_[0] -eq $dh -and $_[1] -eq $id } |% { $_[3] }
      if ($cnt -eq $null) { $cnt = 0 }
      $data = "$data`t$cnt"
    }

    # клиентские дисконнекты
    $data = "$data`t=СУММ($($wsd.cells.item($row,24).Address()):$($wsd.cells.item($row,27).Address()))"
    0,2,4,7 |% {
      $id = $_
      $cnt = $dclientweek |? { $_[0] -eq $dh -and $_[1] -eq $id } |% { $_[2] }
      if ($cnt -eq $null) { $cnt = 0 }
      $data = "$data`t$cnt"
    }
    
    insert-to-excel $wsd $wsd.cells.item($row,1) $data
    
    $d = $d.AddDays(1)
    $row = $row + 1
  }
  
  # форматирование
  $wsd.rows.item(1).font.bold = $true
  $wsd.rows.item(2).font.bold = $true
  $wsd.columns.item(1).font.bold = $true
  $wsd.columns.item(5).NumberFormat = '0,0%'
  $wsd.columns.item(6).NumberFormat = '0,0%'
  
  $row = $row - 1
  
  # проценты сессий с дисконнектами и ливерами
  $chart = $wsg.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlLine
  $chart.SetSourceData($wsd.cells.range($wsd.cells.item(3,1),$wsd.cells.item($row,3)))
  1..2 |% {
    $chart.SeriesCollection($_).Values = $wsd.cells.range($wsd.cells.item(3,$_+4),$wsd.cells.item($row,$_+4))
    $chart.SeriesCollection($_).Name = $wsd.cells.item(2,$_+4).text
  }
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = 'Сессии с дисконнектами и ливерами'
  $chart.parent.Top = 10
  $chart.parent.Left = 10
  $chart.parent.Height = 250
  $chart.parent.Width = 480
  
  # количество дисконнектов
  $chart = $wsg.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlLine
  $chart.SetSourceData($wsd.cells.range($wsd.cells.item(3,1),$wsd.cells.item($row,3)))
  1..2 |% {
    $chart.SeriesCollection($_).Values = $wsd.cells.range($wsd.cells.item(3,8*$_-1),$wsd.cells.item($row,8*$_-1))
    $chart.SeriesCollection($_).Name = $wsd.cells.item(1,8*$_-1).text
  }
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = 'Количество дисконнектов'
  $chart.parent.Top = 10
  $chart.parent.Left = 500
  $chart.parent.Height = 250
  $chart.parent.Width = 480
  
  # дисконнекты по типам
  $chart = $wsg.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlLine
  $chart.SetSourceData($wsd.cells.range($wsd.cells.item(3,1),$wsd.cells.item($row,8)))
  1..7 |% {
    $chart.SeriesCollection($_).Values = $wsd.cells.range($wsd.cells.item(3,$_+7),$wsd.cells.item($row,$_+7))
    $chart.SeriesCollection($_).Name = $wsd.cells.item(2,$_+7).text
  }
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = 'Дисконнекты по типам'
  $chart.parent.Top = 270
  $chart.parent.Left = 10
  $chart.parent.Height = 250
  $chart.parent.Width = 480

  # дисконнекты первых ливеров по типам
  $chart = $wsg.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlLine
  $chart.SetSourceData($wsd.cells.range($wsd.cells.item(3,1),$wsd.cells.item($row,8)))
  1..7 |% {
    $chart.SeriesCollection($_).Values = $wsd.cells.range($wsd.cells.item(3,$_+15),$wsd.cells.item($row,$_+15))
    $chart.SeriesCollection($_).Name = $wsd.cells.item(2,$_+15).text
  }
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = 'Дисконнекты первых ливеров по типам'
  $chart.parent.Top = 270
  $chart.parent.Left = 500
  $chart.parent.Height = 250
  $chart.parent.Width = 480

  # типы клиентских дисконнектов
  $chart = $wsg.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlLine
  $chart.SetSourceData($wsd.cells.range($wsd.cells.item(3,1),$wsd.cells.item($row,5)))
  1..4 |% {
    $chart.SeriesCollection($_).Values = $wsd.cells.range($wsd.cells.item(3,$_+23),$wsd.cells.item($row,$_+23))
    $chart.SeriesCollection($_).Name = $wsd.cells.item(2,$_+23).text
  }
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = 'Клиентские типы DisconnectedByClient'
  $chart.parent.Top = 530
  $chart.parent.Left = 10
  $chart.parent.Height = 250
  $chart.parent.Width = 480  
}

$xlsfile = "$pwd\files\Disconnects-$type-report-$datesuffix.xlsx"
if (test-path $xlsfile) {
  rm $xlsfile
  write "removed existing file $xlsfile"
}

$wb.SaveAs($xlsfile)
write 'created file ' $xlsfile
$wb.Close()
$xc.Quit()


write-host "disconnect-reporter executed in $($exectime.elapsed)"
$exectime.stop()