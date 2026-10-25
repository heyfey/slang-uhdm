// § structMemberDefaultParamRef430
module sub #(parameter c = 2) ();
struct {
	int lo = c;
	int hi;
} p1;
endmodule
module top ();
sub #(.c(5)) u1();
sub u2();
endmodule
