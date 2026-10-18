// § varInitOpCastKept404
module top();
	struct packed {logic [7:0] a; logic [7:0] b; logic [15:0] c;} s;
	integer a = integer'(s);
endmodule
