// § structMemberDefaultParamRef430
module top ();
parameter c = 4'hx;
struct { logic [3:0] lo = c; } p1;
endmodule
