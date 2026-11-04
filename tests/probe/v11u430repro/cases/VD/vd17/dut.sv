// § structMemberDefaultParamRef430
module top ();
parameter c = 4'h5;
struct { struct { bit [3:0] x = c; } in; bit [3:0] hi; } p1;
endmodule
