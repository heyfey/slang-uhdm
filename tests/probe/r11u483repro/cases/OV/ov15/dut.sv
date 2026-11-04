// § clsScopedOvRhsRefObj483
package p;
  localparam W = 16;
endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  sub #(.A(p::W)) u();
endmodule
