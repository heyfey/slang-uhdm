// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::u_t;
endpackage
module top;
  import ap::*;
endmodule
