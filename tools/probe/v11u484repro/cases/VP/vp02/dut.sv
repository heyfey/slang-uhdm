// § aliasTdTargetTopView484 (package alias chain of three, variable of the last at the module)
package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  typedef op2_t op3_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  u::op3_t w;
  assign w = i;
  assign o = w.a;
endmodule
