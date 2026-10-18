// § unpackedTaggedElabSpan402
module top ();
union tagged {
	void invalid;
	bit [3:0] valid;
} un;
initial un = tagged valid (10);
endmodule
