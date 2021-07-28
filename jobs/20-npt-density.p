set datafile commentschars "#@&"
set terminal svg size 500,500
set output "20-npt-density.svg"
set xlabel "Time (ps)" font "Lato,14"
set ylabel "Density (kg/m3)" font "Lato,14"
set label "599283 complexed with 3CL Pro, NVT Equilibration" at graph 0.5,1.035 center font "Lato,12"
set title "Density" font "Lato,20"
plot "20-npt-density.xvg" with lines
