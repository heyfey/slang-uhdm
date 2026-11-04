// § pkgImportUnionCloneHomeInst461
package p;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s_t;
  typedef union packed { s_t s; struct packed { logic [3:0] c; logic [3:0] d; } t; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
