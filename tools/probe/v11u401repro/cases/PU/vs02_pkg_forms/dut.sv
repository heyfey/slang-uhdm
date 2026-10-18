// § unbasedUntypedElabKeepsLiteral401
package p;
  parameter A = '1;
  parameter B = 'z;
  localparam C = '0;
endpackage
module top;
  logic [3:0] a;
  assign a = p::A;
endmodule
