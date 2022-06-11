load "common_twothirds.gnuplot"
set key center right
set xrange [0:1040]

#set x2range [1:27]
set xtics nomirror
#set x2tics (2, 6, 11, 16, 21, 26)

set yrange [0:1100]
#set x2label "Number of Physical Hosts Running Simulation"
set xlabel "Number of Simulated Hosts"
set ylabel "Simulation Time [Min.]"
#set datafile separator "\t"
plot \
  'dist_memcache.dat' using 1:($3*60) title 'gem5' \
      with linespoints, \
  'dist_memcache.dat' using 1:($2*60) title 'QEMU-timing' \
      with linespoints
