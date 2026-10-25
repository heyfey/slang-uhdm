// § structMemberDefaultParamRef430
module top ();
parameter [3:0] c = 4'h5;
struct { bit [3:0] lo = c; } p1;
endmodule
