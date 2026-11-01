// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
  export p::u_t;
endpackage
module top;
  import ap::*;
  u_t v;
endmodule
