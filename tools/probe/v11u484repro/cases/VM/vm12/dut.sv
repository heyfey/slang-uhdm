// § modAliasTdAtBaseClone484 (module alias of a struct with an alias-typed member)
module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; } in_t;
  typedef in_t in2_t;
  typedef struct packed { in2_t x; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  op2_t w;
  assign w = i;
  assign o = w.x.a;
endmodule
