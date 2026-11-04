// residue (no law landed): a type-parameter variable initializer sized by the default type (ModuleEmit, sister ground), see README
module ma #(parameter type p2 = logic [7:0]) (input logic [3:0] i, output logic [3:0] o);
  p2 j = 3;
  always @(i) begin o = i; j++; end
endmodule
module top;
  logic [3:0] i, o;
  ma #(.p2(int)) u1(i, o);
endmodule
