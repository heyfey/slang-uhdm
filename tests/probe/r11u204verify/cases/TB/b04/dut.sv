// § tpArrBoundAtLeftOperand196: a conditional and a modulo-plus-quotient left operand, the module instantiated twice with the type parameter and N overridden
module sub #(parameter int unsigned N = 3, parameter type idx_t = logic [1:0]) (output idx_t o1, o2);
  idx_t [(N>2 ? N : 2)-1:0] a;
  idx_t [N%3+N/2:0] b;
  assign o1 = a[0];
  assign o2 = b[0];
endmodule
module top (output logic [7:0] y1, y2, output logic [1:0] z1, z2);
  sub #(.N(5), .idx_t(logic [7:0])) u1 (.o1(y1), .o2(y2));
  sub u2 (.o1(z1), .o2(z2));
endmodule
