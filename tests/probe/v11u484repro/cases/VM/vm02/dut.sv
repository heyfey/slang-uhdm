// § modAliasPkgBaseTopView484v (module alias of a package packed struct used as a port)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
endpackage
module sub(input p::op_t i, output logic [3:0] o);
  typedef p::op_t op2_t;
  op2_t w;
  assign w = i;
  assign o = w.a ^ w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o);
  sub u(.i(i), .o(o));
endmodule
