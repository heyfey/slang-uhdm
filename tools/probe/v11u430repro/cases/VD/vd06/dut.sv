// § structMemberDefaultParamRef430
module sub #(parameter c = 4'h5) ();
struct { bit [3:0] lo = c; } p1;
endmodule
module top (); sub #(.c(4'h3)) u1(); endmodule
