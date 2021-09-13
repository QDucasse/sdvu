set terminal png
set output "sdvu_synth.png"
set title ' '

# Line style 1
set style line 1 \
    linecolor rgb '#0060ad' \
    linetype 1 linewidth 2 \
    pointtype 7 pointsize 1.5

# Line style 2
set style line 2 \
    linecolor rgb '#abcdef' \
    linetype 1 linewidth 2 \
    pointtype 7 pointsize 1.5

# Axes Label
set xlabel '{/:Bold Number of SDVU cores}' offset 0,-0.5,0
set ylabel '{/:Bold Slice LUTs}' offset 1,0,0
set y2label '{/:Bold % of usage}' offset -1.5,0,0 rotate by 270
set key center top outside

set xrange [0:15]
set x2range [0:15]
set y2range [0:100]
set grid xtics
set y2tics
plot "flux.dat" using 1:2 axis x1y1 title "Slice LUTs" with linespoints linestyle 1,"flux.dat" using 1:3 axis x2y2 title "% of usage" with linespoints linestyle 2