// § structMemberDefaultParamRef430
module top ();
parameter c = -1;
struct { int lo = c; } p1;
endmodule
