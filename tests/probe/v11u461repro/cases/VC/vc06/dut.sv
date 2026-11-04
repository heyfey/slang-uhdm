// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
  int k;
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  import p::*;
  import ap::*;
  u_t v;
  assign v.x = i;
  assign o = v.y;
endmodule
