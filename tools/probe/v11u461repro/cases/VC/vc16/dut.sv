// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { bit [7:0] x; logic [7:0] y; } u_t;
endpackage
package ap;
  import p::*;
  typedef u_t arr_t [2];
  typedef u_t [1:0] parr_t;
endpackage
module top;
  import ap::*;
  parr_t v;
endmodule
