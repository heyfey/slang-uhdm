// § pkgImportUnionCloneHomeInst461
package p;
  typedef bit [7:0] a_t;
  typedef union { a_t x; int y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import p::*;
  import ap::*;
  u_t s;
endmodule
