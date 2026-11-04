// § modAliasPkgBaseTopView484v (module alias of an alias of a package struct (chain across scopes))
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  typedef p::op2_t op3_t;
  op3_t w;
  assign w = i;
  assign o = w.b;
endmodule
