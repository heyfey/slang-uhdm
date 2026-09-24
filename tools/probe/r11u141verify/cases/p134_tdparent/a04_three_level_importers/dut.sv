// § typedefParentLastWriter134
// case a04: three nested modules each importing the package, members read at every level
package p;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } t;
endpackage
module leaf(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  t v;
  assign v = i;
  assign o = v.x;
endmodule
module mid(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  t w;
  assign w = i;
  leaf l(.i(w), .o(o));
endmodule
module top(input logic [7:0] i, output logic [3:0] o, output logic [3:0] o2);
  import p::*;
  t z;
  assign z = i;
  assign o2 = z.y;
  mid m(.i(i), .o(o));
endmodule
