// § pkgImportUnionCloneHomeInst461
package p;
  typedef union { int x; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
