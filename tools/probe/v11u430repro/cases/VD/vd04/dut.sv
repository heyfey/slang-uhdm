// § structMemberDefaultParamRef430
module top ();
parameter c = 'h5;
struct { bit [3:0] lo = c; } p1;
endmodule
