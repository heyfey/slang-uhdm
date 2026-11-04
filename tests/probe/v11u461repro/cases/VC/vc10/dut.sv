// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [1:0][3:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
