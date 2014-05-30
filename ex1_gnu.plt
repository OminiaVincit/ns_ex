#set terminal png
#set output "flow-tcp.png"
set xlabel "time"
set ylabel "window size"
set xrange [1:200]
#set yrange [1:100]
#plot "kadai1_tcp0_out.dat" u 1:7 w l, "kadai1_tcp1_out.dat" u 1:7 w l; pause -1
plot "cwnd-5000.dat" u 1:7 w l; pause -1
