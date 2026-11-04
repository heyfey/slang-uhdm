// § modAliasTdAtBaseClone484 (module alias array of a struct, net of the alias with an unpacked dimension)
module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  op2_t w [2];
  assign w[0] = i;
  assign w[1] = ~i;
  assign o = w[0].a ^ w[1].b;
endmodule
