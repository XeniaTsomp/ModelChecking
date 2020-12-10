// Ethernet Passive Optical Network - EPON
// OLT - Optical Line Terminal
// ONU - Optical Network Unit
// Modeling a sleep control scheme which aims at reducing ONUs' energy consumption and a sleep mode scheduling technique

// Implementation with queue as a module
ctmc
// Model will finish when the OLT and the ONU send a number of transmitted_packets
// scale *10^2
// we run for 100 - 1000 --> 10.000 - 100.000 packets
const int transmitted_packets_down;
// Maximum OLT queue size
const int q_down_max=60;
// Maximum ONU queue size
// 60 --> 6000 packets --> 9MB
const int q_up_max=60;//30; // 4.5M
// Packet arrival rate lamda
// SCALE *10^2
// we run for 0.01 - 1.01 --> 1 - 101 packets/msec
const double arrival_rate_down;//ë_down
const double arrival_rate_up;//ë_up
// Reveive rate of packets (mi = 1)
// SCALE *10^2 --> 100 packets/msec
// =C/L, 1.25 Gbps / 1518 bytes = 1.25*10^9 / 8*1518*10^3 packets/msec
// =12.5*10^5 / 12*10^3 = 100 packets/msec
const double receive_rate_down;
const double receive_rate_up;
//constants for cycles 
const int y=1;
const int x=1;

//Tsleep
const double sleep_time_cycle; // eg.20 msec
const double listening_time_cycle; // 8 msec

// TRansition rates
const double rate_s2l = 1/2 ;		// msec
const double rate_s2s = 1/sleep_time_cycle; // msec
const double rate_l2l = 1/listening_time_cycle; // msec
const double rate_l2s = pow(10,3)/2.88 ; // microsec
const double rate_s2a = 1/2 ;		// msec
//ONU upstream
const int transmitted_packets_up;

// Formula finish represents the final state of the model
// Model will finish when the OLT will have send transmitted_packets and ONU will have received all packets
// and the ONU will have send transmitted packets and OLT will have received all packets
formula finish = ((q_down=0) & (q_up=0) & (packets_down = transmitted_packets_down) & (packets_up=transmitted_packets_up));

// The OLT has a queue/ONU where ONU's packets are arrived
// With the increase of packet arrival rate queue size increases and then (queue becomes full) packets dropped
// When an ONU sleeps, its downstream traffic is bufferd by the OLT and its upstream traffic is bufferd by the ONU. Then ONU turns to active mode and receives its packets.
module QUEUE_DOWN

	// q = number of packets currently in queue
	q_down : [0..q_down_max] init 0;
	
	// A packet arrives at OLT. 
	[arrive_down] q_down < min(q_down+1,q_down_max) -> arrival_rate_down : (q_down'=min(q_down+1,q_down_max)) ;

	// Packet buffering at OLT. a) once it sends a sleep request. b) the ONU is in listen mode and there is no upstream traffic. 
	// c) when the ONU transits to listen mode after an uninterrupted sleep mode and no upstream traffic occurs. d) the ONU is in sleep mode.  
	[buffer_down] q_down<min(q_down+1,q_down_max) & ((r!=0 & pm=2 & s!=2)| (r=2 & pm=1 &s=2)| (r!=1 & s=0 & pm=0)) -> arrival_rate_down : (q_down'=min(q_down+1,q_down_max));
	
	// Packet drop at OLT (when queue is full, independent of ONU power mode)
	[drop_down] q_down=q_down_max -> arrival_rate_down : (q_down'=q_down);

	// A packet is received by ONU 
	[received_by_ONU] q_down>=1 -> (q_down'=q_down-1);
	
	// [] finish -> true;

endmodule

// The ONU has a queue where users' packets are arrived
// With the increase of packet arrival rate queue size increases and then (queue becomes full) packets dropped
// When an ONU sleeps its upstream traffic is bufferd by the ONU and then packets dropped
module QUEUE_UP

	// n = number of frames currently in queue
	q_up : [0..q_up_max] init 0;
	
	// A packet arrives at ONU. 
	[arrive_up] q_up < min(q_up+1,q_up_max) -> arrival_rate_up : (q_up'=min(q_up+1,q_up_max)) ;

	// Packet buffering at ONU. The ONU buffers its packets while ONU sleeps.
	[buffer_up] q_up<min(q_up+1,q_up_max) & (pm=0) -> arrival_rate_up : (q_up'=min(q_up+1,q_up_max));

	// Packet drop at ONU (when queue is full, indepentent of OLT state)
	[drop_up] q_up=q_up_max -> arrival_rate_up : (q_up'=q_up);

	// A Packet received by OLT 
	[received_by_OLT] q_up>=1 -> (q_up'=q_up-1);

	// [] finish -> true;

endmodule

// OLT - Optical Line Terminal
// Broadcasts the downstream traffic to all ONUs
//Initially, ONU is in active power mode. Packets which arrive in OLT's queue and received by ONU.
//Then the OLT sends sleep requests when there are no packets in its queue and ONU is in active mode.
//After that, the OLT buffers the packets that arrive to its queue. 
module OLT

	// Count the number of transmitted packets 
	packets_down: [-1..transmitted_packets_down] init 0;

	//0:do not send request, 1:send request, 2:request received
	r:[0..2] init 0;

	//counter of sleep requests
	sleep_counter:[-1..transmitted_packets_down] init 0;

//energy-aware mechanism message exchange

	//OLT sends sleep request. If the OLT's queue is empty, ONU is in active power mode, no sleep request sent and the number of downstream packets is less 
	//than the transimitted downstream packets, then OLT turns to state r=1 which depicts that a sleep request has been sent. 
	[sleep_request](q_down=0) & (pm=2) & (r=0) & packets_down<transmitted_packets_down  -> (r'=1);

	//ONU receives request. If ONU is in active power mode and a sleep request has been sent, then OLT turns to state r=2 which depicts that the sleep request has been received.
	[request_received](pm=2) & (r=1) -> (r'=2);

	//ONU sends ack. If ONU is in active power mode and a sleep request has been received then ONU sents an ack message. The OLT stays in the same state, r=2
	[ack_sent](pm=2) & (r=2) -> (r'=r);

	//ONU sends nack. If ONU is in active power mode and a sleep request has been received then ONU sents an ack message. 
	//The OLT turns to the same state, r=0 which allows it to send another one sleep request.
	[nack_sent_by_ONU](pm=2) & (r=2) -> (r'=0);


//Downstream traffic - packets' transmission-reception
	
	// Send packet to ONU if ONU is in active or listening mode and packets_down < transmitted_packets_down
	// Synchronisation: The rate of this transition is equal to the product of the two individual rates i.e. arrival_rate * 1
	
	//A downstream packet arrives in OLT's queue, if ONU is in active power mode and no sleep request has been sent or if the ack message has been received and ONU transits 
	//from listen mode to active beacause of incoming upstream traffic . 
	[arrive_down] packets_down<min(packets_down+1,transmitted_packets_down) & ((pm=2 & r=0)|(pm=2 & r=2 & s=2)|(pm=1 & r=0 & s=0)) -> 1: (packets_down'=min(packets_down+1,transmitted_packets_down)); 
	
	// Packet buffering at OLT if ONU sleeps or while ONU is in listen or active power mode and a sleep request has been sent or received and packets < transmitted_packets
	[buffer_down] packets_down<min(packets_down+1,transmitted_packets_down) -> 1 : (packets_down'=min(packets_down+1,transmitted_packets_down)); 
	
	// Packet drop at OLT if queue is full --> retain the queue size and mode
	[drop_down] packets_down<min(packets_down+1,transmitted_packets_down) -> 1 : (packets_down'=min(packets_down+1,transmitted_packets_down));
	
	//OLT do not send sleep request if ONU is in sleep mode. 
	[county] pm=0 -> (r'=0);
	
	// A packet is received by OLT if queue_up>=1 and ONU is in active power mode. 
	[received_by_OLT] pm=2 -> receive_rate_up : (r'=r);
	//[] finish -> true;

endmodule

// ONU - Optical Network Unit
// Obtain downstream and upstream packets destined to itself
// The ONU has 3 power modes:listen, sleep and active
//ONU replies to a sleep request with ack message when its queue is empty, else replies with nack message.
//When ONU is in active mode, packets arrive to its queue and then received by OLT if no ack message sent to OLT.   
//When ONU is in listen mode, packets arrive to its queue, ONU turns to active mode and sends them to OLT, OLT receives packets and ONU turns to listen mode.   
//When ONU is in sleep mode, packets are buffered in its queue.
//ONU turns to listen mode in ns, so the time that is spent is negible.   
module ONU
//ONU states 
//0:sleep state, 1:listen state, 2:active
// Model begins with ONU in active mode
	//states of ONU
	pm:[0..2] init 1;

	// sleep cycles sc: 0 .. y
	sc : [0..y] init 0;

	// listening cycles lc: 0 .. x
	lc : [0..x] init 0;

	//count the number of transmitted frames from ONU to upstream 
	packets_up : [-1..transmitted_packets_up] init 0;
	//count nack messages
	nack_counter:[-1..transmitted_packets_up] init 0;
	//count ack messages
	ack_counter:[-1..transmitted_packets_up] init 0;

	//0: ack or nack not sent, 1: ack or nack sent , 2:ack received
	s:[0..2] init 0;

//energy-aware mechanism message exchange

	//OLT sends sleep request if ONU is in active power mode and no sleep request has been sent. 
	[sleep_request](pm=2) & (r=0) -> (s'=0) & (pm'=pm);

	//ONU receives request if it is in active power mode and a sleep request has been sent
	[request_received](pm=2) & (r=1)-> (s'=s) & (pm'=pm); 

	//ONU sends ack. If it is in active power mode, q_up is empty, a sleep request has been received and no message has been sent. 
	//then, ONU turns to state s=1, which depicts that a message has been sent.  
	[ack_sent](pm=2) & (r=2) & (s=0) & (q_up=0) -> (s'=1) & (pm'=pm);

	//ONU sends nack. If it is in active power mode, q_up is not empty, a sleep request has been received and no message has been sent. 
	//then, ONU turns to state s=1 which depicts that a message has been sent.
	[nack_sent_by_ONU](pm=2) & (r=2) & (s=0) & (q_up>0) -> (s'=1) & (pm'=pm);

//packets' transmission-reception

	// a packet arrives in active power mode 
	[arrive_down] ((pm=2 & r=0)|(pm=2 & r=2 & s=2)|(pm=1 & r=0 & s=0)) -> 1 : (pm'=2);
	
	// A packet is reveived by ONU if it is in active mode and no request sent or a sleep request received and an ack or nack received
	[received_by_ONU] ((pm=2 & r=0)|(pm=2 & r=2 & s=2)) -> receive_rate_down : (pm'=2);

//ONU's power modes	

	// Switch from active to listenig mode if queue=0
	// R_a2l in state machine = does not considered (ns)
	
	// When a sleep request received by the ONU, an ack message send if there is no upstream traffic. Then, the ack message received by the OLT and the ONU transits to listen mode.
	// If there is upstream traffic when the ONU is in listen mode, it transits from listen mode to active and the OLT stops buffering its packets.
	// When their queues are empty then the ONU goes back to listen mode.    
	[active2listening] ((pm=2 & (r=2) & (s=1) & q_up=0) | (pm=2 & s=2 & q_down=0 & q_up=0)) & packets_down<=transmitted_packets_down -> (s'=2) & (pm'=1) & (lc'=0);

	// Switch from listening mode. Stays in listen mode after sleep period or after an ack replied message.  
	[countx] pm=1 & lc < x & (((r=0) & (s=0))|((r=2) & (s!=0))) -> rate_l2l: (pm'=pm) & (lc'=lc+1);
	
	//ONU turns from listen to sleep mode when a sleep request and an ack message received. 
	//Or when ONU was in sleep mode, since no packets arrived at its queue. After a sleep period (county) of 20ms r'=0.
	//So, r=0 and s=0 because no sleep and ack sent after a sleep cycle. Then, turns to listen mode and then back to sleep mode. 
	//The s state turns to 0 when ONU transits to sleep mode.	
	[listening2sleep] pm=1 & (lc=x) & ((r=2) & (s!=0)|(r=0) & (s=0)) -> rate_l2s: (pm'=0) & (lc'=0) & (s'=0);
      
	// Switch to sleep mode
	[county] pm=0 & sc<y -> rate_s2s: (pm'=pm) & (sc'=sc+1);
	
	//Switch to listen mode. If there are no buffered packets in their queues the ONU turns to listen mode
	[sleep2listening] pm=0 & sc=y  & q_down=0 & q_up=0 -> rate_s2l: (pm'=1) & (sc'=0);
	
	//Switch to active mode. If there are buffered packets in their queues the ONU turns to active mode and a wake up message sent
	[sleep2active] pm=0 & sc=y & (q_down>0|q_up>0) -> rate_s2a: (pm'=2) & (sc'=0);
	
//Upstream traffic

	// Send packet to OLT if ONU is in active or listening mode and packets_up< transmitted_packets_up
	// Synchronisation: The rate of this transition is equal to the product of the two individual rates i.e. arrival_rate * 1
	
	//Upstream in active mode. Packets arrive at ONU's queue when no ack/nack message sent by ONU or when the ONU turns to active mode after a sleep period or when ONU sends a nack message. 
	[arrive_up] packets_up<min(packets_up+1,transmitted_packets_up) & pm=2 & (s!=1 | ((r=0|r=2) & s=1)) -> 1: (packets_up'=min(packets_up+1,transmitted_packets_up)); 
	
	//Upstream in listen mode. Packets arrive at ONU's queue if a sleep request received or if ONU transits from sleep to listen mode and a packet arrives at its queue in listen mode. 
	//To send its packets, ONU turns to active mode and then to listen mode.	
	[arrive_up] packets_up<min(packets_up+1,transmitted_packets_up) & (pm=1) & ((r=2)|((r=0) & (s=0))) & (lc<=x) -> 1: (packets_up'=min(packets_up+1,transmitted_packets_up)) & (pm'=2); 

	// Packet buffering at ONU if ONU sleeps and packets_up < transmitted_packets_up
	[buffer_up] packets_up<min(packets_up+1,transmitted_packets_up) -> 1 : (packets_up'=min(packets_up+1,transmitted_packets_up)); 
	
	// Packet drop at ONU if queue is full --> retain the queue size and mode
	[drop_up] packets_up<min(packets_up+1,transmitted_packets_up) -> 1 : (packets_up'=min(packets_up+1,transmitted_packets_up));

endmodule
//-----------------------------------------------------


//----------------My rewards-------------------------//

//calculate the expected number of sleep requests
rewards "sleep_requests"
	[sleep_request] true:1;
endrewards
//calculate the expected number of nack messages
rewards "nack_messages"
	[nack_sent_by_ONU] true:1;
endrewards
//calculate the expected number of ack messages
rewards "ack_messages"
	[ack_sent] true:1;
endrewards
//the expected size of queue within C0 time units of operation
rewards "queue_size_up"
	true : q_up;
endrewards

// Reward structures

//the expected size of queue within C0 time units of operation
rewards "queue_size_down"
	true : q_down;
endrewards

rewards "Q_delay"
	pm=2: q_down/arrival_rate_down;
endrewards

rewards "W_delay"
	pm=0: sleep_time_cycle/2;
endrewards

rewards "delay"
	pm=2: q_down/arrival_rate_down; // http://www.cs.toronto.edu/~marbach/COURSES/CSC358_S14/delay.pdf, queuing and transmission delay
	pm=0: sleep_time_cycle/2;
endrewards

rewards "allstates"
    true : 1;
endrewards

//rewards "queue_size"
  //  [arrive] true : 1;
//endrewards

//the expected number of sleep cycles within C0 time units of operation
rewards "total_sleep"
	[county] true: 1/rate_s2s;
	//[buffer_down] true: 1/arrival_rate;
	//[buffer_up] true: 1/arrival_rate;
	//pm=0: 1;
endrewards

//the expected number of listening cycles within C0 time units of operation
rewards "total_listen"
	[countx] true: 1/rate_l2l;
	//pm=1: 1;
endrewards


//the expected number of active cycles within C0 time units of operation
rewards "total_active"
	//pm=2: 1;
	[arrive_down] true: 1/arrival_rate_down;
	[arrive_up] true: 1/arrival_rate_up;
	[received_by_ONU] true: 1/receive_rate_down;
	[received_by_OLT] true: 1/receive_rate_up;
endrewards

//the expected number of active cycles within C0 time units of operation

rewards "total_buffer"
	[buffer_down] true: 1/arrival_rate_down;
endrewards

rewards "total_arrival"
	[arrive_down] true: 1/arrival_rate_down;
	[arrive_up] true: 1/arrival_rate_up;
	[buffer_down] true: 1/arrival_rate_down;
	[buffer_up] true: 1/arrival_rate_up;
endrewards

rewards "total_receive"
	[received_by_ONU] true: 1/receive_rate_down;
	[received_by_OLT] true: 1/receive_rate_up;	
endrewards

rewards "total_trans"
	[listening2sleep] true: 1/rate_l2s;
	[sleep2listening] true: 1/rate_s2l;
	[sleep2active] true: 1/rate_s2a;
endrewards

rewards "energy_consumption"
      pm=0 : 0.75;//1*50;
      pm=1 : 1.28;//1*170;
      pm=2 : 3.85;//1*750;
endrewards

// count drop packets
rewards "drops"
	[drop_down] true : 1;
endrewards
