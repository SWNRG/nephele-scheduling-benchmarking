set term postscript eps color
set autoscale
unset log
unset label
set xtic auto
set xtics font 'Arial,14' rotate by -90
set ytics font 'Arial,14'
set xlabel font 'Arial,18'
set ylabel font 'Arial,18'
set title font 'Arial,18'
set key font 'Arial,16'
set ytic auto
set title '""'
set xlabel '"k0s'
set ylabel 'plugins"'
set xrange "ram"
set key auto bottom
set style line 1 lt 1 lw 5 lc rgb 'black'
set style line 2 lt 1 lw 5 lc rgb 'gray'
set style line 3 lt 1 lw 5 lc rgb 'red'
set style line 4 lt 1 lw 5 lc rgb 'blue'
set style line 5 lt 1 lw 5 lc rgb 'yellow'
set style line 6 lt 1 lw 5 lc rgb 'green'
set style line 7 lt 3 lw 3 lc rgb 'black'
set style line 8 lt 6 lw 3 lc rgb 'black'
set style line 9 lt 1 lw 3 lc rgb 'black'
set style line 10 lt 2 lw 5 lc rgb 'black'
set style line 11 lt 3 lw 5 lc rgb 'black'
set style line 12 lt 6 lw 5 lc rgb 'black'
set style line 13 lt 2 lw 3 lc rgb 'black'
plot 'net.txt'  using kuberouter:xtic(1) title 'right' with lines linestyle 1\
, 'net.txt'  using calico title '11' with lines linestyle 6\
, 'net.txt'  using  title '12' with lines linestyle 8\
