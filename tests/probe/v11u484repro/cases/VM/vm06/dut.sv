// § modAliasTdAtBaseClone484 (parameterized module alias of a parameter-width struct, two instances)
module sub #(parameter int W = 4) (input logic [2*W-1:0] i, output logic [W-1:0] o);
  typedef struct packed { logic [W-1:0] a; logic [W-1:0] b; } op_t;
  typedef op_t op2_t;
  op2_t w;
  assign w = i;
  assign o = w.a;
endmodule
module top(input logic [15:0] i, output logic [3:0] o1, output logic [7:0] o2);
  sub #(4) u1(i[7:0], o1);
  sub #(8) u2(i, o2);
endmodule
