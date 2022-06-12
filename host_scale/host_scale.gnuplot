load "common_twothirds.gnuplot"
set key bottom right
set xrange [1.5:22]
set yrange [0:210]
set xlabel "Number of Simulated Hosts"
set ylabel "Simulation Time [Min.]"
#set datafile separator "\t"
plot \
  'host_scale.dat' using ($1+1):2 notitle with linespoints
