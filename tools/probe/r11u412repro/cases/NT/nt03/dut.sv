// § modNettypeTypedef412
module sub();
	nettype logic [3:0] l_net;
	typedef logic z_t;
endmodule
module top();
	sub u1();
	sub u2();
	nettype real r_net;
	r_net w;
endmodule
