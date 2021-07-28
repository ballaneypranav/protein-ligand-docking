set datafile commentschars "#@&"
set terminal svg size 500,500
set output "9-minimization-potential.svg"
set xlabel "Energy Minimization Step" font "Lato,14"
set ylabel "Potential Energy (kJ/mol)" font "Lato,14"
set label "LIGX complexed with 3CL Pro" at graph 0.5,1.035 center font "Lato,12"
set title "Energy Minimization" font "Lato,20"
plot "9-minimized-potential.xvg" with lines

