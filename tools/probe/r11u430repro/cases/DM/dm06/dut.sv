// § structMemberDefaultParamRef430
module top ();
parameter c = 4'h5;
struct {
	bit [3:0] lo = c;
} p1, p2;
endmodule
