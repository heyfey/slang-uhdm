// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { struct packed { logic [3:0] a; logic [3:0] b; } s; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
