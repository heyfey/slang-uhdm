// § interconnectNetNone412
module top();
	interconnect [3:0] b4;
	interconnect a, c;
	mod_i m1(b4[0]);
	mod_i m2(a);
endmodule
module mod_i(input in);
endmodule
