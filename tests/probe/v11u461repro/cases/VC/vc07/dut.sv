// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
  class K;
    u_t m;
  endclass
endpackage
module top;
  import ap::*;
endmodule
