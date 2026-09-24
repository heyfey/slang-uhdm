// § taggedUnionElabSpan137
module top ();
	union tagged packed {
		bit [6:0] v1;
		bit [6:0] v2;
	} un;
	initial un = tagged v2 (10);
endmodule
