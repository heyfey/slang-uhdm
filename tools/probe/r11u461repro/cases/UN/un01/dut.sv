// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
  int k;
endpackage
module top;
  import p::*;
  import ap::*;
endmodule
