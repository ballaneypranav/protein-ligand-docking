set datafile commentschars "#@&"
set terminal svg size 500,500
set output "16-nvt-temperature.svg"
set xlabel "Time (ps)" font "Lato,14"
set ylabel "Temperature (K)" font "Lato,14"
set label "599283 complexed with 3CL Pro, NVT Equilibration" at graph 0.5,1.035 center font "Lato,12"
set title "Temperature" font "Lato,20"
plot "16-nvt-temperature.xvg" with lines
