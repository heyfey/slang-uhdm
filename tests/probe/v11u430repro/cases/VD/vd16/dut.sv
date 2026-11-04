// § structMemberDefaultParamRef430
module top (output bit [3:0] o);
parameter c = 4'h5;
struct { bit [3:0] lo = c; bit [3:0] hi; } p1;
assign o = p1.lo;
endmodule
