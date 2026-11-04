// § pkgImportUnionCloneHomeInst461
package q;
  typedef logic [7:0] byte_t;
endpackage
package p;
  typedef union packed { q::byte_t x; bit [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
