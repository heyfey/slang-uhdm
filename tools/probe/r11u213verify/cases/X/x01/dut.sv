// § tpCastUseBindsDefDefault206 § parenCastWidthRefPkgBare207 (a type-parameter cast in a loop generate whose type default and operand read a package paren-cast width parameter)
package pk;
  localparam dw = 4;
  localparam m = (dw)'('hf);
endpackage
module x01 import pk::*; #(parameter type t = logic [dw-1:0]) (input logic s, output t o);
  t [1:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'((dw)'(i)) : t'(m);
  end
  assign o = x[0] ^ x[1];
endmodule
