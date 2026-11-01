// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { enum logic [1:0] {A, B, C} e; bit [1:0] b; } u_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
