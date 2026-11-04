// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { struct packed { logic [3:0] a; logic [3:0] b; } s; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
  int k;
endpackage
module top(input logic [7:0] i, output logic [3:0] o, output logic [7:0] z);
  import ap::*;
  import p::*;
  u_t v;
  assign v.y = i;
  assign o = v.s.a;
  assign z = v;
endmodule
