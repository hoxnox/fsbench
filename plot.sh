#!/bin/sh

RESULT=$2
echo "<h1>Filesystem test</h1><br><table><tr><td>" > $RESULT
OP=`echo $1 | awk -F '-' '{print $2}'`
OP_CLASS=$OP
if [ "$OP" == "randread" ]; then
	OP_CLASS="read"
fi
if [ "$OP" == "randwrite" ]; then
	OP_CLASS="write"
fi

datafile=$(mktemp /tmp/storage_test.XXXXXXXXXX.dat)

jq ".jobs[] | {name:.jobname,data:.$OP_CLASS,cpu:.sys_cpu} | \
	.name,\"\t\",                                      \
	.data.lat_ns.mean,\"\t\",                          \
	.data.bw_mean,\"\t\",                              \
	.data.iops,\"\t\",                                 \
	.cpu,\"\n\"                                        \
   " -jc $1 > $datafile

xsize=600
ysize=400

# lat
gnuplot <<- EOF
xsize=$xsize
ysize=$ysize

set terminal svg size xsize,ysize font "Helvetica,10"
set encoding iso_8859_1

set title "$OP latency"
set nokey
#set xtics border in scale 1,0.5 nomirror rotate by -45 autojustify

set ylabel 'latency (nanosec)'
set format y "%12.3f"
set xlabel 'threads'

set output "$datafile.lat.svg"
plot "$datafile" using 2:xtic(1) with lines
EOF

# bw
gnuplot <<- EOF
xsize=$xsize
ysize=$ysize

set terminal svg size xsize,ysize font "Helvetica,10"
set encoding iso_8859_1

set title "$OP bandwidth"
set nokey
set xtics border in scale 1,0.5 nomirror rotate by -45 autojustify

set ylabel 'bandwidth (KB/s)'
set format y "%12.3f"
set xlabel 'threads'

set output "$datafile.bw.svg"
plot "$datafile" using 3:xtic(1) with lines
EOF

# iops
gnuplot <<- EOF
xsize=$xsize
ysize=$ysize

set terminal svg size xsize,ysize font "Helvetica,10"
set encoding iso_8859_1

set title "$OP iops"
set nokey
set xtics border in scale 1,0.5 nomirror rotate by -45 autojustify

set ylabel 'iops'
set format y "%12.3f"
set xlabel 'threads'

set output "$datafile.iops.svg"
plot "$datafile" using 4:xtic(1) with lines
EOF

# cpu
gnuplot <<- EOF
xsize=$xsize
ysize=$ysize

set terminal svg size xsize,ysize font "Helvetica,10"
set encoding iso_8859_1

set title "$OP cpu"
set nokey
set xtics border in scale 1,0.5 nomirror rotate by -45 autojustify

set ylabel 'cpu'
set format y "%12.3f"
set xlabel 'threads'

set output "$datafile.cpu.svg"
plot "$datafile" using 5:xtic(1) with lines
EOF

sed 1d "$datafile.lat.svg" >> $RESULT
echo "</td><td>" >> $RESULT
sed 1d "$datafile.bw.svg" >> $RESULT
echo "</td></tr><tr><td>" >> $RESULT
sed 1d "$datafile.iops.svg" >> $RESULT
echo "</td><td>" >> $RESULT
sed 1d "$datafile.cpu.svg" >> $RESULT
echo "</td></tr></table>" >> $RESULT

rm "$datafile.lat.svg"
rm "$datafile.bw.svg"
rm "$datafile.iops.svg"
rm "$datafile.cpu.svg"

rm $datafile
