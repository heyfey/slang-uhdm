// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { int x; int unsigned y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
