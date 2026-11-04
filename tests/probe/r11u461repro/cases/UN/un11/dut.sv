// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
package bp;
  import ap::*;
endpackage
module top;
  import bp::*;
endmodule
