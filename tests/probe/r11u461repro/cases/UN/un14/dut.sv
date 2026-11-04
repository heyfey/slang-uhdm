// § pkgImportUnionCloneHomeInst461
package p;
  typedef logic [7:0] b_t;
  typedef union packed { b_t x; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
