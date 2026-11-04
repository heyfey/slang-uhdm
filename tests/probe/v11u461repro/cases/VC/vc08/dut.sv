// § pkgImportUnionCloneHomeInst461
package p;
  typedef struct packed { struct packed { union packed { logic [3:0] a; bit [3:0] b; } u; bit c; } s; bit [7:0] y; } s_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
