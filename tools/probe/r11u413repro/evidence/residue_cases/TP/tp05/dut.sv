// residue (no law landed): a type-parameter variable initializer sized by the default type (ModuleEmit, sister ground), see README
module ma #(parameter type p2 = byte) (input logic [3:0] i, output logic [3:0] o);
  p2 j = 1;
  p2 k = 'h7;
  always @(i) begin o = i; j++; k++; end
endmodule
module top;
  logic [3:0] i, o;
  ma #(.p2(longint)) u1(i, o);
  ma u2(i, o);
endmodule
