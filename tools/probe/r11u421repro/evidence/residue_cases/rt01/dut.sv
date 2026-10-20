// residue (no law landed): a type-parameter variable initializer sized by the default type (sister ground, p88), see README
module ma #(parameter type p2 = shortint) (input logic i);
  p2 j = 0;
endmodule
module top; logic i; ma #(.p2(int)) u1(i); endmodule
