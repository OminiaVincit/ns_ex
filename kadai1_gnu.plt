set terminal png
set output "flow-tcp.png"
set xlabel "time"
set ylabel "window size"
set xrange [1:200]
#set yrange [1:100]
plot "tcp_flow0_file.dat" u 1:2 w l, "tcp_flow1_file.dat" u 1:2 w l; pause -1
#plot "cwnd-5000.dat" u 1:7 w l; pause -1
