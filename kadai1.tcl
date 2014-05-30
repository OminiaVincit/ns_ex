set ns [new Simulator]

$ns color 1 red
$ns color 2 blue
$ns color 3 cyan
$ns color 4 green
$ns color 5 orange
$ns color 6 black
$ns color 7 yellow
$ns color 8 purple
$ns color 9 gold
$ns color 10 chocolate

set nums 1

#Trace setup
#set fall [open kadai1.tr w]
#$ns trace-all $fall

#set fnam [open kadai1.nam w]
#$ns namtrace-all $fnam

#set ftcp [open kadai1.tcp w]

# Open the window plot file
set tcp_flow0_file [open tcp_flow0_file.dat w]
set tcp_flow1_file [open tcp_flow1_file.dat w]

# Dumbbell topology 
#
# s0              r0
#   \            /
#    \          /
#     n0------n1
#    /          \
#   /            \
# s1              r1
#
set s0 [$ns node]
set s1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]
set r0 [$ns node]
set r1 [$ns node]

$ns duplex-link $s0 $n0 10Mb 10ms DropTail
$ns duplex-link $s1 $n0 10Mb 10ms DropTail

$ns duplex-link $n0 $n1 0.5Mb 30ms DropTail
$ns duplex-link-op $n0 $n1 queuePos 0.5

$ns duplex-link $n1 $r0 10Mb 10ms DropTail
$ns duplex-link $n1 $r1 10Mb 10ms DropTail

$ns duplex-link-op $n0 $s0 orient up-left
$ns duplex-link-op $n0 $s1 orient down-left
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $r0 orient up-right
$ns duplex-link-op $n1 $r1 orient down-right

$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n0 10

Agent/TCP set window_ 200000
Agent/TCP set ssthresh_ 200000

# Setup the first TCP connection
set tcp0 [new Agent/TCP/Newreno]
$ns attach-agent $s0 $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $r0 $sink0

$ns connect $tcp0 $sink0
$tcp0 set fid_ 1
$tcp0 set packetSize_ 522

### Setup over a FTP over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

### Setup second TCP conection

set tcp1 [new Agent/TCP/Newreno]
$ns attach-agent $s1 $tcp1 

set sink1 [new Agent/TCPSink]
$ns attach-agent $r1 $sink1

$ns connect $tcp1 $sink1
$tcp1 set packetSize_ 522
$tcp1 set fid_ 2

# FTP sender: Transport and Application
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

#$tcp0 trace cwnd_
#$tcp0 trace ssthresh_
#$tcp0 attach-trace $ftcp

#$tcp1 trace cwnd_
#$tcp1 trace ssthresh_
#$tcp1 attach-trace $ftcp

# CBR sender: Transport and Application
#set udp0 [new Agent/UDP]
#$ns attach-agent $s0 $udp0

#set cbr0 [new Application/Traffic/CBR]
#$cbr0 set packetSize_ 1000
#$cbr0 set interval_ 0.05
#$cbr0 attach-agent $tcp1
#$udp0 set class_ 0

#set udp1 [new Agent/UDP]
#$ns attach-agent $s1 $udp1

#set cbr1 [new Application/Traffic/CBR]
#$cbr1 set packetSize_ 1000
#$cbr1 set interval_ 0.05
#$cbr1 attach-agent $tcp1
#$udp1 set class_ 1

# CBR receiver: Transport and Application
#set null0 [new Agent/Null]
#$ns attach-agent $r1 $null0
#$ns connect $tcp1 $null0

#set null1 [new Agent/Null]
#$ns attach-agent $r1 $null1
#$ns connect $tcp1 $null1

#
# Scenario
#
proc finish {} {
	#global ns fall fnam ftcp
	#$ns flush-trace
	#close $fall
	#close $fnam
	#close $ftcp
	exit 0
}

# plotWindow(tcpSource, file): write CWND from $tcpSource to output file
# every 0.1 sec
proc plotWindow {tcpSource file} {
	global ns
	set time 0.1
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	set wnd [$tcpSource set window_]
	puts $file "$now $cwnd"
	$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

# Start plotWindow for TCP 1 and 2
$ns at 0.1 "plotWindow $tcp0 $tcp_flow0_file"
$ns at 0.1 "plotWindow $tcp1 $tcp_flow1_file"

$ns at 1.0 "$ftp0 start; 
$ns trace-annotate \"Time:[$ns now] Start FTP\""
$ns at 20.0 "$ftp1 start; 
$ns trace-annotate \"Time:[$ns now] Start FTP\""

#$ns at 51.0 "$cbr0 start;
#$ns trace-annotate \"Time:[$ns now] Start CBR interval [$cbr0 set interval_ 0.05] size [$cbr0 set packetSize_]\""

#$ns at 51.0 "$cbr1 start;
#$ns trace-annotate \"Time:[$ns now] Start CBR interval [$cbr1 set interval_] size [$cbr1 set packetSize_]\""

#$ns at 101.0 "$cbr1 stop; $ns trace-annotate \"Time:[$ns now] Stop CBR\""
#$ns at 101.0 "$cbr0 stop; $ns trace-annotate \"Time:[$ns now] Stop CBR\""
$ns at 500.0 "$ftp0 stop; $ns trace-annotate \"Time:[$ns now] Stop FTP\""
$ns at 500.0 "$ftp1 stop; $ns trace-annotate \"Time:[$ns now] Stop FTP\""
$ns at 500.25 "finish"
#
# start simulatuion
#
$ns run
