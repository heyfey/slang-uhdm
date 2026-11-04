// gE — CLASS B: a LITERAL-bound package vector typedef.  Its bound can never
// unfold, so only the Typedef_alias half can reach it.
package p;
  typedef logic [7:0] uint8_t;
  parameter uint8_t PC = 8'hCC;
endpackage
module top;
  import p::*;
  logic [7:0] x;
  assign x = PC;
endmodule
