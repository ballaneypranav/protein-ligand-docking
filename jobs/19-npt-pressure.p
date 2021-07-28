set datafile commentschars "#@&"
set terminal svg size 500,500
set output "19-npt-pressure.svg"
set xlabel "Time (ps)" font "Lato,14"
set ylabel "Pressure (bar)" font "Lato,14"
set label "599283 complexed with 3CL Pro, NPT Equilibration" at graph 0.5,1.035 center font "Lato,12"
set title "Pressure" font "Lato,20"
plot "19-npt-pressure.xvg" with lines
