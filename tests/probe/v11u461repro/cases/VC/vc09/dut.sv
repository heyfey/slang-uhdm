// § pkgImportUnionCloneHomeInst461
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { union packed { e_t e; bit [1:0] b; } u; bit [7:0] y; } s_t;
endpackage
package ap;
  import p::*;
endpackage
module top;
  import ap::*;
endmodule
