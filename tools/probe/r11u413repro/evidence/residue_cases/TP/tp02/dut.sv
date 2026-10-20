// residue (no law landed): a type-parameter variable initializer sized by the default type (ModuleEmit, sister ground), see README
module ma #(parameter type p2 = shortint) (input logic [3:0] i, output logic [3:0] o);
  p2 j = 0;
  always @(i) begin o = i; j++; end
endmodule
module top;
  logic [3:0] i, o;
  ma u1(i, o);
endmodule
