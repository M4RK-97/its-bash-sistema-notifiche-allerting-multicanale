<?php

$file = '/opt/alerting/variables.data';

if (!file_exists($file)) {
    die("No data");
}

$data = [];

foreach (file($file) as $line) {
    if (strpos($line, '=') !== false) {
        list($k, $v) = explode('=', trim($line), 2);
        $data[$k] = $v;
    }
}

function services($str) {
    $out = [];
    foreach (explode(',', $str) as $s) {
        if (!$s) continue;
        list($n, $st) = explode(':', $s);
        $out[] = [$n, $st];
    }
    return $out;
}

?>

<h1>Dashboard</h1>

<p>Status: <b><?= $data['OVERALL_STATUS'] ?></b></p>
<p>Time: <?= $data['TIMESTAMP'] ?></p>

<h2>Resources</h2>
<p>Disk: <?= $data['DISK_USAGE'] ?>%</p>
<p>Load: <?= $data['LOAD_AVG'] ?></p>

<h2>Services</h2>
<ul>
<?php foreach (services($data['SERVICES_STATUS']) as $s): ?>
  <li><?= $s[0] ?> → <?= $s[1] ?></li>
<?php endforeach; ?>
</ul>