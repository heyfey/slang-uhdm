// § modAliasPkgBaseTopView484v (module alias of a package struct, the package wildcard-imported by top and by sub, port connection)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
endpackage
module sub(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  typedef op_t loc_t;
  loc_t w;
  assign w = i;
  assign o = w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  typedef op_t loc_t;
  loc_t w;
  assign w = i;
  sub u(.i(w), .o(o));
endmodule
