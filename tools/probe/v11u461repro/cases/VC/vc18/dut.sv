// § pkgImportUnionCloneHomeInst461
package p;
  typedef bit [7:0] a_t;
  typedef union packed { a_t x; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import p::*;
  import ap::*;
  u_t s;
endmodule
