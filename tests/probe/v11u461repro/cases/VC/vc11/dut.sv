// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
package bp;
  import p::*;
endpackage
module top;
  import ap::*;
  import bp::*;
endmodule
