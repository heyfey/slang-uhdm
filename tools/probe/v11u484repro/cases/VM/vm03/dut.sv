// § modAliasPkgBaseTopView484v (output port typed by a package alias, module alias of the same)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
endpackage
module sub(input logic [7:0] i, output p::op2_t o);
  typedef p::op_t loc_t;
  loc_t w;
  assign w = i;
  assign o = w;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub u(.i(i), .o(o));
endmodule
