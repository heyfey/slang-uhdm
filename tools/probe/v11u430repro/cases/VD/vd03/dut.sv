// § structMemberDefaultParamRef430
module top ();
parameter c = 5;
struct { int lo = c; int hi; } p1;
endmodule
