// § modAliasPkgBaseTopView484v (two modules each aliasing one package struct)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
endpackage
module s1(input logic [7:0] i, output logic [3:0] o);
  typedef p::op_t x_t;
  x_t w;
  assign w = i;
  assign o = w.a;
endmodule
module s2(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  typedef op_t x_t;
  x_t w;
  assign w = i;
  assign o = w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o1, o2);
  s1 u1(i, o1);
  s2 u2(i, o2);
endmodule
