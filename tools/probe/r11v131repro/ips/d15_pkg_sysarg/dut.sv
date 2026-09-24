// § constCtxCallArgInner131v
package pk;
  localparam logic [31:0] A = 32'hcafef00d;
  localparam int B = $countones(A[15 -: 8]);
endpackage
module top ();
endmodule
