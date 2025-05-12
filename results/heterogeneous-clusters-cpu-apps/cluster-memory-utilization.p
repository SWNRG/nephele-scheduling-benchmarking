set term postscript eps solid
set autoscale
unset log
unset label
set xtic auto
set xtics font 'Courier,14' rotate by -45 scale 0
set ytics font 'Courier,14'
set xlabel font 'Courier,18'
set ylabel font 'Courier,18'
set title font 'Courier,18'
set key font 'Courier,14'
set ytic auto
set title ''
set xlabel 'Cluster'
set ylabel 'Memory (%)'
set yrange [0:100]
set key top right
# Line style 1: Solid line with black markers
set style line 1 lc rgb '#000000' lw 3 pt 8 ps 1.5
# Line style 2: Dashed line with thicker gray markers
set style line 2 lc rgb '#555555' lw 4 dt 2 pt 7 ps 1.5
# Line style 3: Dotted line with black markers
set style line 3 lc rgb '#000000' lw 3 dt 3 pt 3 ps 1.5
# Line style 4: Dash-dot line with thicker gray markers
set style line 4 lc rgb '#555555' lw 4 dt 1 pt 7 ps 1.5
# Line style 5: Dashed line with black-filled circle markers
set style line 5 lc rgb '#000000' lw 3 dt 2 pt 6 ps 1.5
# Line style 6: Solid line with gray-filled square markers
set style line 6 lc rgb '#555555' lw 3 pt 4 ps 1.5
# Line style 7: Dotted line with black-filled triangle markers
set style line 7 lc rgb '#000000' lw 3 dt 3 pt 5 ps 1.5
# Line style 8: Dash-dot line with thicker gray markers
set style line 8 lc rgb '#555555' lw 4 dt 1 pt 2 ps 1.5
plot '/root/results/cluster-memory-utilization.csv.s.t' using 2:xtic(1) title 'light-cpu' with linespoints ls 1\
, '/root/results/cluster-memory-utilization.csv.s.t' using 3 title 'medium-cpu' with linespoints ls 2\
, '/root/results/cluster-memory-utilization.csv.s.t' using 4 title 'large-cpu' with linespoints ls 3\
, '/root/results/cluster-memory-utilization.csv.s.t' using 5 title 'mixture-cpu' with linespoints ls 4
