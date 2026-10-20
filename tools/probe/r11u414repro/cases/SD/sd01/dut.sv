// § structMemberDefault414
module top ();
parameter c = 4'h5;
struct {
	bit [3:0] lo = c;
	bit [3:0] hi;
} p1;
endmodule
