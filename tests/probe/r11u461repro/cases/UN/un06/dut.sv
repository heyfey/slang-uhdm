// § pkgImportUnionCloneHomeInst461
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef union packed { e_t x; logic [1:0] y; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
