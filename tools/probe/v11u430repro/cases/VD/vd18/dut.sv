// § structMemberDefaultParamRef430
module top ();
parameter c = 5'd17;
parameter e = 1;
struct { int lo = c; int z = e; } p1;
endmodule
