// § typedefParentLastWriter134
// case a01: a package struct typedef imported by an interface and by a module, members read in the module
package p;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } t;
endpackage
interface ifc;
  import p::*;
  t s;
endinterface
module top(output logic [3:0] o);
  import p::*;
  ifc u();
  t v;
  assign v = u.s;
  assign o = v.y;
endmodule
