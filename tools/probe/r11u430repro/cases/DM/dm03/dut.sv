// § structMemberDefaultParamRef430
module top ();
localparam int W = 7;
struct {
	int a = W;
	int b = 1 + 2;
} p1;
endmodule
