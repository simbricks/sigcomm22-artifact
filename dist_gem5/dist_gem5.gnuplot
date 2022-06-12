load "common_twothirds.gnuplot"
set key left top

set xlabel "Number of Simulated Hosts"
set ylabel "Simulation Time [Min.]"

set yrange [0:2050]
set xtics scale 0, 0 ("2" 0, "8" 1, "16" 2, "32" 3)


set boxwidth 0.3
set style fill solid

Speedup(baseline,new) = sprintf("-%d%%", (1-$3/$2)*100)

plot \
  'dist_gem5.dat' using ($0-0.16):2 title "dist-gem5" with boxes ls 1,\
  'dist_gem5.dat' using ($0+0.16):3 title "\\sysname" with boxes ls 2,\
  'dist_gem5.dat' using ($0):($2+120):(Speedup($2,$3)) notitle with labels