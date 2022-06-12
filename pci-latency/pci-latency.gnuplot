load "common_twothirds.gnuplot"

set boxwidth 0.4
set style fill solid

set style line 1 \
    linecolor rgb '#bcbddc' \
    linetype 1 linewidth 2 \
    pointtype 7 pointsize 1.5
set style line 2 \
    linecolor rgb '#9e9ac8' \
    linetype 1 linewidth 2 \
    pointtype 7 pointsize 1.5
set style line 3 \
    linecolor rgb '#807dba' \
    linetype 1 linewidth 2 \
    pointtype 13 pointsize 1.3   
set style line 4 \
    linecolor rgb '#6a51a3' \
    linetype 1 linewidth 2 \
    pointtype 13 pointsize 1.3  
set style line 5 \
    linecolor rgb '#54278f' \
    linetype 1 linewidth 2 \
    pointtype 13 pointsize 1.3  

set ylabel "Simulation Time [Min.]"
set yrange [0:670]
set xlabel "PCIe latency [ns]"
set xrange [-0.5:2.5]
unset xtics
set xtics nomirror
set xtics ("10" 0, "50" 0.5, "100" 1, "500" 1.5, "1000" 2)
unset key
plot \
'pci-latency.dat' every 6::0 using (0):2 with boxes ls 1,\
'pci-latency.dat' every 6::1 using (0.5):2 with boxes ls 2,\
'pci-latency.dat' every 6::2 using (1):2 with boxes ls 3,\
'pci-latency.dat' every 6::3 using (1.5):2 with boxes ls 4,\
'pci-latency.dat' every 6::4 using (2):2 with boxes ls 5

