// § pkgImportUnionCloneHomeInst461
package p;
  parameter int W = 6;
  typedef union packed { logic [W-1:0] x; bit [W-1:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
