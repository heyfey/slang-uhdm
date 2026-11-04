// § structMemberDefaultParamRef430
module top ();
parameter c = 4'h5, d = 3'b101;
struct { bit [3:0] lo = c; bit [2:0] hi = d; } p1;
endmodule
