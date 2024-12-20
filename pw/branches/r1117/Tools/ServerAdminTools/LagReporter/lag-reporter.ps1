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

function insert-to-excel ($worksheet, $cell, $str) {
  Add-Type -Assembly PresentationCore
  [Windows.Clipboard]::SetText($str, [Windows.TextDataFormat]'Text')
  $worksheet.range($cell.Address()).pasteSpecial(-4104) | out-null # xlPasteAll = -4104
}

function write-event-by-types ($worksheet, $type, $time, $title, $startrow, $col) {
  write-host 'writing ' $type ' ' $time

  # запрос данных из бд
  $data = exec-sql "
  select typeid, count(*), sum($($type)_$($time)_evt), round(avg($($type)_$($time)_timemax))
  from event_exceedingsteptime_agg_report
  where datehierarchy between $dh1 and $dh2
    and $($type)_$($time)_evt != 0
  group by typeid"
  
  # формирование строки для вставки в Excel
  $cells = $worksheet.cells
  $row = $startrow + 2
  $text = "`t$title`nTypeID	s2p	events	timemax	%events`n"
  $data |% {
    $text += $_.replace(',',"`t") + "`n"
    $row++
  }
  $text += "`t`t" + ('=СУММ({0}:{1})' -f $cells.item($startrow+2,$col+2).Address(), $cells.item($row-1,$col+2).Address())

  $sumtext = ''
  ($startrow+2)..($row-1) |% {
    $sumtext += "={0}/{1}`n" -f $cells.item($_,$col+2).Address(), $cells.item($row,$col+2).Address()
  }  
  
  # украшалки
  $worksheet.range($cells.item($startrow+2,$col),$cells.item($row,$col)).NumberFormat = '@'
  $worksheet.range($cells.item($startrow+2,$col+4),$cells.item($row-1,$col+4)).NumberFormat = '0%'
  $worksheet.range($cells.item($startrow,$col),$cells.item($startrow+1,$col+4)).font.bold = $true
  $cells.item($row,$col+2).font.bold = $true
  
  # вставка в Excel
  insert-to-excel $worksheet $worksheet.cells.item($startrow,$col) $text
  insert-to-excel $worksheet $worksheet.cells.item($startrow+2,$col+4) $sumtext
  
  return $($row-$startrow)
}

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
  $chart.Parent.Height  = 200
  $chart.Parent.Width = 380
}


# ---------------------------------------------------------------------------------------
# start ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------

$exectime = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "`n`nstarted lag-reporter"
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
    exec-sql "select aggregate_event_exceedingsteptime($dh1)"
  }
  if ($type -eq 'weekly') {
    $d = $date1
    while ($d -lt $date2) {
      exec-sql "select aggregate_event_exceedingsteptime($($d.tostring('yyyyMMdd')))"
      $d = $d.AddDays(1)
    }
  }
}

# ---------------------------------------------------------------------------------------
# Формирование Excel файла

# создание COM объекта Excel
$xc = New-Object -ComObject "Excel.Application"
write 'started Excel.Application'
$wb = $xc.Workbooks.Add()

# создается еще несколько листов
$wb.Worksheets.Add() | out-null
$wb.Worksheets.Add() | out-null
if ($type -eq 'daily') {
  $wb.Worksheets.Add() | out-null
  $wb.Worksheets.Add() | out-null
}

# ---------------------------------------------------------------------------------------
# Общий отчет

$SHEET = 1

$wsg = $wb.Worksheets.item($SHEET)
$wsd = $wb.Worksheets.item($SHEET+1)

$wsg.name = 'Overall (graphs)'
$wsd.name = 'Overall (data)'

# заполнение разных частей документа
$row = 3

$inserted1 = write-event-by-types $wsd 'jitter' '100' 'Max <200' $row 1
$inserted2 = write-event-by-types $wsd 'lag'    '100' 'Max <200' $row 8
if ($inserted1 -gt $inserted2) { $row = $row + $inserted1 + 2} else { $row = $row + $inserted2 + 2 }

$inserted1 = write-event-by-types $wsd 'jitter' '200' 'Max 200-300' $row 1
$inserted2 = write-event-by-types $wsd 'lag'    '200' 'Max 200-300' $row 8
if ($inserted1 -gt $inserted2) { $row = $row + $inserted1 + 2} else { $row = $row + $inserted2 + 2 }

$inserted1 = write-event-by-types $wsd 'jitter' '300' 'Max 300-400' $row 1
$inserted2 = write-event-by-types $wsd 'lag'    '300' 'Max 300-400' $row 8
if ($inserted1 -gt $inserted2) { $row = $row + $inserted1 + 2} else { $row = $row + $inserted2 + 2 }

$inserted1 = write-event-by-types $wsd 'jitter' '400' 'Max 400-500' $row 1
$inserted2 = write-event-by-types $wsd 'lag'    '400' 'Max 400-500' $row 8
if ($inserted1 -gt $inserted2) { $row = $row + $inserted1 + 2} else { $row = $row + $inserted2 + 2 }

$inserted1 = write-event-by-types $wsd 'jitter' '500' 'Max >500' $row 1
$inserted2 = write-event-by-types $wsd 'lag'    '500' 'Max >500' $row 8
if ($inserted1 -gt $inserted2) { $row = $row + $inserted1 + 2} else { $row = $row + $inserted2 + 2 }

# наведение красоты
write 'advanced formatting'
$wsd.cells.item(1,2) = 'Jitters (avg 98-102)'
$wsd.cells.item(1,9) = 'Lags (avg <98 or >102)'
$wsd.cells.item(1,2).font.bold = $true
$wsd.cells.item(1,9).font.bold = $true
$wsd.cells.item(1,2).font.size = 14
$wsd.cells.item(1,9).font.size = 14

$wsd.columns.item(1).columnwidth = 13
$wsd.columns.item(8).columnwidth = 13

$data = exec-sql "
  select count(distinct stpid),
         count(distinct case when (lag_100_evt > 0 or lag_200_evt > 0 or lag_300_evt > 0 or 
                                   lag_400_evt > 0 or lag_500_evt > 0) and typeid&b'00000110' != 0::bit(8)
                             then stpid else null end) as server_lag,
         count(distinct case when (jitter_100_evt > 0 or jitter_200_evt > 0 or jitter_300_evt > 0 or 
                                   jitter_400_evt > 0 or jitter_500_evt > 0) and typeid&b'00000110' != 0::bit(8)
                             then stpid else null end) as server_jitter,
         count(distinct case when (lag_100_evt > 0 or lag_200_evt > 0 or lag_300_evt > 0 or 
                                   lag_400_evt > 0 or lag_500_evt > 0) and typeid&b'11111001' != 0::bit(8)
                             then stpid else null end) as client_lag,
         sum(total_evt)
  from event_exceedingsteptime_agg_report
  where datehierarchy between $dh1 and $dh2"

$data = $data.split(',')

$totals2p = exec-sql "
  select count(stp.id)
  from sessiontoplayer stp
    join gamesession gs on gs.id = stp.gamesession and gs.location = stp.location
  where gs.timehierarchyid between $dh1 and $dh2
    and gs.starttime between '$($date1.tostring('yyyy-MM-dd'))' and '$($date2.tostring('yyyy-MM-dd HH:mm:ss'))'
    and gs.sessiontype = 4"


$alldata =
"Total s2p:	$totals2p
S2p with lags:	$($data[0])	=O3/O2
S2p with server lags:	$($data[1])	=O4/O2
S2p with server jitters:	$($data[2])	=O5/O2
S2p with client lags:	$($data[3])	=O6/O2
Total events:	$($data[4])"

insert-to-excel $wsd $wsd.cells.item(2,14) $alldata
$wsd.cells.range('P3:P7').numberformat = '0%'
$wsd.cells.range('N2:S7').font.bold = $true

# легенда по типам лагов
write 'lags typeid info'
$wsd.cells.range('N10:O17').numberformat = '@'
$wsd.cells.range('N10:O17').interior.colorindex = 36
$alldata = 
"LogicStepTime	00000001
ServerStepTime	00000010
NoDataTime	00000100
AltTabFlag	00001000
DragFlag	00010000
InactiveFlag	00100000
RpcQueueTime	01000000
OpenedFileFlag	10000000"
insert-to-excel $wsd $wsd.cells.item(10,14) $alldata
$wsd.columns.item(14).columnwidth = 20
$wsd.columns.item(15).columnwidth = 15

# подписи к колонкам с данными для диаграмм
$alldata = "All events`tServerStepTime`tNoDataTime`tQueue`tFile`tLogic`tInactive`tAvg by s2p`t`tAll"
insert-to-excel $wsd $wsd.cells.item(19,15) $alldata
$wsd.cells.range($wsd.cells.item(19,15),$wsd.cells.item(19,25)).font.bold = $true

# выборка данных для диаграмм
$col = 15
@("","'00000010'","'00000100'","'01000000'","'10000001','10000010'","'00000001'") |% {
  $clause = ""
  if ($_ -ne "") { $clause = "and typeid in ($_)" }
  $data = exec-sql "
    select sum(jitter_100_evt), sum(jitter_200_evt), sum(jitter_300_evt), sum(jitter_400_evt), sum(jitter_500_evt),
           sum(lag_100_evt), sum(lag_200_evt), sum(lag_300_evt), sum(lag_400_evt), sum(lag_500_evt)
    from event_exceedingsteptime_agg_report
    where datehierarchy between $dh1 and $dh2
      $clause"
  $data = $data.replace(',',"`n")
  insert-to-excel $wsd $wsd.cells.item(20,$col) $data
  $col++
}

# суммы здесь же
insert-to-excel $wsd $wsd.cells.item(20,14) "jitter <200
jitter 200-300
jitter 300-400
jitter 400-500
jitter >500
lag <200
lag 200-300
lag 300-400
lag 400-500
lag >500"

insert-to-excel $wsd $wsd.cells.item(20,21) "=O20-СУММ(P20:T20)`t=U20/O2
=O21-СУММ(P21:T21)`t=U21/O2
=O22-СУММ(P22:T22)`t=U22/O2
=O23-СУММ(P23:T23)`t=U23/O2
=O24-СУММ(P24:T24)`t=U24/O2
=O25-СУММ(P25:T25)`t=U25/O2
=O26-СУММ(P26:T26)`t=U26/O2
=O27-СУММ(P27:T27)`t=U27/O2
=O28-СУММ(P28:T28)`t=U28/O2
=O29-СУММ(P29:T29)`t=U29/O2"

$alldata = "=СУММ(O20:O29)`t=СУММ(P20:P29)`t=СУММ(Q20:Q29)`t=СУММ(R20:R29)`t=СУММ(S20:S29)`t=СУММ(T20:T29)`t=СУММ(U20:U29)`t=СУММ(V20:V29)"
insert-to-excel $wsd $wsd.cells.item(30,15) $alldata


# сводные данные
$alldata = 
"heavy jitter`t=СУММ(P22:P24)`t=СУММ(Q22:Q24)`t=СУММ(R22:R24)`t=СУММ(S22:S24)`t=СУММ(T22:T24)
heavy lags`t=СУММ(P27:P29)`t=СУММ(Q27:Q29)`t=СУММ(R27:R29)`t=СУММ(S27:S29)`t=СУММ(T27:T29)
light jitter`t=СУММ(P20:P21)`t=СУММ(Q20:Q21)`t=СУММ(R20:R21)`t=СУММ(S20:S21)`t=СУММ(T20:T21)
light lags`t=СУММ(P25:P26)`t=СУММ(Q25:Q26)`t=СУММ(R25:R26)`t=СУММ(S25:S26)`t=СУММ(T25:T26)"
insert-to-excel $wsd $wsd.cells.item(32,15) $alldata
$wsd.cells.range('V20:V30').numberformat = '0,000'

$alldata = '=O20-СУММ(P20:T20)'
21..29 |% { $alldata = "$alldata`n=O$_-СУММ(P$_`:T$_)" }
insert-to-excel $wsd $wsd.cells.item(20,21) $alldata

$alldata = 
"jitter`t=СУММ(O20:O24)
lags`t=СУММ(O25:O29)

server`t=СУММ(P20:Q29)
client`t=СУММ(R20:T29)

active`t=СУММ(P20:T29)
inactive`t=СУММ(U20:U29)

heavy jitter`t=СУММ(P32:T32)
heavy lags`t=СУММ(P33:T33)
inactive`t=Y27
light jitter`t=СУММ(P34:T34)
light lags`t=СУММ(P35:T35)"
insert-to-excel $wsd $wsd.cells.item(20,24) $alldata


# добавление диаграмм (380x200)
add-chart $wsg $wsd.range('N20:N29') $wsd.range('O20:O29') 'Total: by type' 10 10
add-chart $wsg $wsd.range('P19:T19') $wsd.range('P30:T30') 'Total: by area' 10 400
add-chart $wsg $wsd.range('R19:T19') $wsd.range('R30:T30') 'Client: all by type' 10 790
add-chart $wsg $wsd.range('X23:X24') $wsd.range('Y23:Y24') 'Total: Server vs Client' 220 10
add-chart $wsg $wsd.range('X20:X21') $wsd.range('Y20:Y21') 'Total: Jitters vs Lags' 220 400
add-chart $wsg $wsd.range('X26:X27') $wsd.range('Y26:Y27') 'Total: Active vs Inactive' 220 790
add-chart $wsg $wsd.range('X29:X33') $wsd.range('Y29:Y33') 'Total: Delay types' 430 10
add-chart $wsg $wsd.range('P19:T19') $wsd.range('P33:T33') 'Total: Heavy Lags' 430 400
add-chart $wsg $wsd.range('P19:T19') $wsd.range('P32:T32') 'Total: Heavy Jitter' 430 790


# ---------------------------------------------------------------------------------------
# Отчет по количеству сессий

$SHEET = 6

if ($type -eq 'daily') {

$wsg = $wb.Worksheets.item($SHEET)
$wsg.name = 'By sessions (graphs)'
$wsd=$wb.Worksheets.item($SHEET+1)
$wsd.name = 'By sessions (data)'

$STEPS = @(0,1,3,6,10,20,30,40,50,70,100,150,200)

$arr = @{}
$STEPS |% { $arr[$_] = 0 }

# ALL DATA
$str = ''

$data = exec-sql "select evts, count(*) from (
  select stpid, sum(total_evt) as evts
  from event_exceedingsteptime_agg_report
  where datehierarchy between $dh1 and $dh2
  group by stpid
  ) sq 
  group by evts
  order by evts"

$alldata = ,@()
$data |% {
  $d = $_.split(',')
  $alldata += ,@($d[0],$d[1])
}

for ($i=1; $i -lt $STEPS.Length; $i++) {
  $sum = 0
  $alldata |? { [int]$_[0] -gt $STEPS[$i-1] -and [int]$_[0] -le $STEPS[$i] } |% {
    $sum += [int]$_[1]
  }
  $str += "$($STEPS[$i])`t$sum`n"
}
$sum = 0
$alldata |? { [int]$_[0] -gt $STEPS[$i-1] } |% {
  $sum += [int]$_[1]
}
$str += "1000`t$sum`n"

insert-to-excel $wsd $wsd.cells.item(2,1) $str
$rc = $STEPS.length + 1 # rowcount

$chart = $wsg.shapes.addChart().chart
$chart.ChartType = [microsoft.office.interop.excel.XlChartType]::xlColumnClustered
$chart.SetSourceData($wsd.cells.range("A2:A$rc"))
$chart.SeriesCollection(1).XValues = $wsd.cells.range("A2:A$rc")
$chart.SeriesCollection(1).Values = $wsd.cells.range($wsd.cells.item(2,2),$wsd.cells.item($rc,2))
$chart.SeriesCollection(1).Name = 'Все'
$chart.HasTitle = $true
$chart.ChartTitle.Text = 'Распределение количества jitters+lags на сессию'
$chart.parent.Top = 10
$chart.parent.Left = 10
$chart.parent.Height = 250
$chart.parent.Width = 480

# LAGS & JITTERS
foreach ($ltype in 'lag','jitter') {
  # init
  if ($ltype -eq 'lag') {
    $colshift = 5
    $charttop = 270
  }
  if ($ltype -eq 'jitter') {
    $colshift = 13
    $charttop = 530
  }
  
  $str = ''
  
  $data = exec-sql "select evts, count(*)
    from (
    select stpid, 
           sum($($ltype)_100_evt)+sum($($ltype)_200_evt)+sum($($ltype)_300_evt)+
           sum($($ltype)_400_evt)+sum($($ltype)_500_evt) as evts
    from event_exceedingsteptime_agg_report
    where datehierarchy between $dh1 and $dh2
    group by stpid
    ) sq 
    group by evts
    order by evts"
  
  $alldata = ,@()
  $data |% {
    $d = $_.split(',')
    $alldata += ,@($d[0],$d[1])
  }
  
  for ($i=1; $i -lt $STEPS.Length; $i++) {
    $sum = 0
    $alldata |? { [int]$_[0] -gt $STEPS[$i-1] -and [int]$_[0] -le $STEPS[$i] } |% {
      $sum += [int]$_[1]
    }
    $str += "$($STEPS[$i])`t$sum`n"
  }
  $sum = 0
  $alldata |? { [int]$_[0] -gt $STEPS[$i-1] } |% {
    $sum += [int]$_[1]
  }
  $str += "1000`t$sum`n"

  insert-to-excel $wsd $wsd.cells.item(2,$colshift-1) $str

  $chart = $wsg.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.XlChartType]::xlColumnClustered
  $chart.SetSourceData($wsd.cells.range("A2:A$rc"))
  $chart.SeriesCollection(1).XValues = $wsd.cells.range("A2:A$rc")
  $chart.SeriesCollection(1).Values = $wsd.cells.range($wsd.cells.item(2,$colshift),$wsd.cells.item($rc,$colshift))
  $chart.SeriesCollection(1).Name = 'Все'
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = "Распределение количества $($ltype)s на сессию"
  $chart.parent.Top = $charttop
  $chart.parent.Left = 10
  $chart.parent.Height = 250
  $chart.parent.Width = 480

  $ser = 1
  $chart = $wsg.shapes.addChart().chart
  $chart.ChartType = [microsoft.office.interop.excel.XlChartType]::xlColumnClustered
  $chart.SetSourceData($wsd.cells.range("A2:E$rc"))
  $chart.SeriesCollection(1).XValues = $wsd.cells.range("A2:A$rc")
  foreach($len in '100','200','300','400','500') {
    $str = ''
    
    $data = exec-sql "select evts, count(*)
      from (
      select stpid, 
             sum($($ltype)_$($len)_evt) as evts
      from event_exceedingsteptime_agg_report
      where datehierarchy between $dh1 and $dh2
      group by stpid
      ) sq 
      group by evts
      order by evts"
    
    $alldata = ,@()
    $data |% {
      $d = $_.split(',')
      $alldata += ,@($d[0],$d[1])
    }    
    
    for ($i=1; $i -lt $STEPS.Length; $i++) {
      $sum = 0
      $alldata |? { [int]$_[0] -gt $STEPS[$i-1] -and [int]$_[0] -le $STEPS[$i] } |% {
        $sum += [int]$_[1]
      }
      $str += "$sum`n"
    }
    $sum = 0
    $alldata |? { [int]$_[0] -gt $STEPS[$i-1] } |% {
      $sum += [int]$_[1]
    }
    $str += "$sum`n"

    insert-to-excel $wsd $wsd.cells.item(2,$colshift+$ser) $str
    $chart.SeriesCollection($ser).Values = $wsd.cells.range($wsd.cells.item(2,$colshift+$ser),$wsd.cells.item($rc,$colshift+$ser))
    $chart.SeriesCollection($ser).Name = $len
    $ser += 1
  }
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = "Распределение количества $($ltype)s на сессию (по типам)"
  $chart.parent.Top = $charttop
  $chart.parent.Left = 500
  $chart.parent.Height = 250
  $chart.parent.Width = 480
}

$wsd.Range('A1:R1').font.bold = $true
$header = "All`tTotal`t`tLags`tTotal`t100-200`t200-300`t300-400`t400-500`t500+`t`tJitters`tTotal`t100-200`t200-300`t300-400`t400-500`t500+"
insert-to-excel $wsd $wsd.cells.item(1,1) $header
}

# ---------------------------------------------------------------------------------------
# Отчет по качеству сессий для игроков

$SHEET = 3

# Веса каждого типа лагов (для расчета качества)
$weights = @{
  'jitter100' = 0.007;
  'jitter200' = 0.015;
  'jitter300' = 0.025;
  'jitter400' = 0.06;
  'jitter500' = 0.08;
  'lag100'    = 0.10;
  'lag200'    = 0.14;
  'lag300'    = 0.18;
  'lag400'    = 0.25;
  'lag500'    = 0.30;
}

# Данные по UX в разных разрезах
@('Traffic UX', 'Adaptive UX', 'Gameplay UX') |% {

$wsd=$wb.Worksheets.item($SHEET)
$wsd.name = $_

$typeid_clause = switch ($_) {
  'Traffic UX'  { "typeid in (b'00000010', b'00000110')" }
  'Adaptive UX' { "typeid&b'00000100'!=0::bit(8) and typeid&b'11111001' = 0::bit(8)" }
  'Gameplay UX' { "typeid&b'11000011'!=0::bit(8) and typeid&b'00111000' = 0::bit(8)" }
}

# Получение общих данных
$data = exec-sql "
  select
    locale,
    count(case when pts <= 2.0 then stpid else null end),
    count(case when pts > 2.0 and pts <= 4.0 then stpid else null end),
    count(case when pts > 4.0 and pts <= 6.0 then stpid else null end),
    count(case when pts > 6.0 and pts <= 8.0 then stpid else null end),
    count(case when pts > 8 then stpid else null end)
  from 
  (
  select
    locale,
    stpid,
    sum(jitter_100_evt) * $($weights['jitter100']) + 
    sum(jitter_200_evt) * $($weights['jitter200']) + 
    sum(jitter_300_evt) * $($weights['jitter300']) + 
    sum(jitter_400_evt) * $($weights['jitter400']) + 
    sum(jitter_500_evt) * $($weights['jitter500']) + 
    sum(lag_100_evt)    * $($weights['lag100']) + 
    sum(lag_200_evt)    * $($weights['lag200']) + 
    sum(lag_300_evt)    * $($weights['lag300']) + 
    sum(lag_400_evt)    * $($weights['lag400']) + 
    sum(lag_500_evt)    * $($weights['lag500']) pts
  from event_exceedingsteptime_agg_report
  where datehierarchy between $dh1 and $dh2
    and $typeid_clause
  group by locale, stpid
  ) sq
  group by locale
  union
  select
    'zzz',
    count(case when pts <= 2.0 then stpid else null end),
    count(case when pts > 2.0 and pts <= 4.0 then stpid else null end),
    count(case when pts > 4.0 and pts <= 6.0 then stpid else null end),
    count(case when pts > 6.0 and pts <= 8.0 then stpid else null end),
    count(case when pts > 8 then stpid else null end)
  from 
  (
  select
    stpid,
    sum(jitter_100_evt) * $($weights['jitter100']) + 
    sum(jitter_200_evt) * $($weights['jitter200']) + 
    sum(jitter_300_evt) * $($weights['jitter300']) + 
    sum(jitter_400_evt) * $($weights['jitter400']) + 
    sum(jitter_500_evt) * $($weights['jitter500']) + 
    sum(lag_100_evt)    * $($weights['lag100']) + 
    sum(lag_200_evt)    * $($weights['lag200']) + 
    sum(lag_300_evt)    * $($weights['lag300']) + 
    sum(lag_400_evt)    * $($weights['lag400']) + 
    sum(lag_500_evt)    * $($weights['lag500']) pts
  from event_exceedingsteptime_agg_report
  where datehierarchy between $dh1 and $dh2
    and $typeid_clause
  group by stpid
  ) sq  
  order by locale"


# Формирование блока по каждой локали
$row = 16
$chartcount = 1
$wsd.columns.item(1).columnwidth = 13

$data |% {

  $d = $_.split(',')
  $name = if ($d[0] -eq 'zzz') { 'All' } else { $d[0] }
  $alldata = "$name players
UX mark`tTotal
Excellent`t$($d[1])
Comfortable`t$($d[2])
Fairly`t$($d[3])
Uncomfortable`t$($d[4])
Poor`t$($d[5])"

  insert-to-excel $wsd $wsd.cells.item($row,1) $alldata

  # Данные по локали с разделением по кластерам
  $locale_clause = '1=1'
  if ($name -ne 'All') { $locale_clause = "locale = '$name'" }
  $data2 = exec-sql "
    select
      coalesce(cluster,'zzz'),
      count(case when pts <= 2.0 then stpid else null end),
      count(case when pts > 2.0 and pts <= 4.0 then stpid else null end),
      count(case when pts > 4.0 and pts <= 6.0 then stpid else null end),
      count(case when pts > 6.0 and pts <= 8.0 then stpid else null end),
      count(case when pts > 8 then stpid else null end)
    from 
    (
    select
      cluster,
      stpid,
      sum(jitter_100_evt) * $($weights['jitter100']) + 
      sum(jitter_200_evt) * $($weights['jitter200']) + 
      sum(jitter_300_evt) * $($weights['jitter300']) + 
      sum(jitter_400_evt) * $($weights['jitter400']) + 
      sum(jitter_500_evt) * $($weights['jitter500']) + 
      sum(lag_100_evt)    * $($weights['lag100']) + 
      sum(lag_200_evt)    * $($weights['lag200']) + 
      sum(lag_300_evt)    * $($weights['lag300']) + 
      sum(lag_400_evt)    * $($weights['lag400']) + 
      sum(lag_500_evt)    * $($weights['lag500']) pts
    from event_exceedingsteptime_agg_report
    where datehierarchy between $dh1 and $dh2
      and $locale_clause
      and $typeid_clause
    group by cluster, stpid
    ) sq
  group by cluster
  order by cluster"
  
  $col = 3
  $poors = "% Poor`t={1}/СУММ({0}:{1})" -f $wsd.cells.item($row+2,2).Address(), $wsd.cells.item($row+6,2).Address()
  $data2 |% {
    $d2 = $_.replace(',',"`n").replace('zzz','NOINFO')
    insert-to-excel $wsd $wsd.cells.item($row+1,$col) $d2
    $poors += "`t={1}/СУММ({0}:{1})" -f $wsd.cells.item($row+2,$col).Address(), $wsd.cells.item($row+6,$col).Address()
    $col++    
  }
  insert-to-excel $wsd $wsd.cells.item($row+7,1) $poors
  
  $wsd.cells.range($wsd.cells.item($row,1),$wsd.cells.item($row+1,$col)).font.bold = $true
  $wsd.cells.range($wsd.cells.item($row+7,1),$wsd.cells.item($row+7,$col)).font.bold = $true
  $wsd.cells.range($wsd.cells.item($row+7,2),$wsd.cells.item($row+7,$col)).NumberFormat = '0%'
  $wsd.cells.item($row,1).font.size = 14

  # Построение чарта
  $chart = $wsd.shapes.addChart().chart
  $chart.SetSourceData($wsd.cells.range($wsd.cells.item($row+2,2),$wsd.cells.item($row+6,2)))
  $chart.SeriesCollection(1).XValues = $wsd.cells.range($wsd.cells.item($row+2,1),$wsd.cells.item($row+6,1))
  $chart.SeriesCollection(1).Values = $wsd.cells.range($wsd.cells.item($row+2,2),$wsd.cells.item($row+6,2))
  $chart.ChartType = [microsoft.office.interop.excel.xlChartType]::xlPie
  $chart.ChartStyle = 26
  $chart.ApplyDataLabels()
  $chart.SeriesCollection(1).DataLabels().ShowPercentage = $true
  $chart.SeriesCollection(1).DataLabels().ShowValue = $false
  $chart.HasTitle = $true
  $chart.ChartTitle.Text = $wsd.cells.item($row,1).text
  $chart.Parent.Top  = 10
  $chart.Parent.Height = 200
  $chart.Parent.Width = 300
  if ($name -eq 'All') { 
    $chart.Parent.Left = 10 
  }
  else { 
    $chart.Parent.Left = 320*$chartcount 
  }

  $chartcount++
  $row += 9
}

insert-to-excel $wsd $wsd.cells.item(1,1) ""

$SHEET++
}

# ---------------------------------------------------------------------------------------
# Сохранение документа

$xlsfile = "$pwd\files\Lag-Reports-$type-$datesuffix.xlsx"
if (test-path $xlsfile) {
  rm $xlsfile
  write "removed existing file $xlsfile"
}

$wb.SaveAs($xlsfile)
write 'created file ' $xlsfile
$wb.Close()
$xc.Quit()

write-host 'lag-reporter executed in ' $exectime.elapsed
$exectime.stop()