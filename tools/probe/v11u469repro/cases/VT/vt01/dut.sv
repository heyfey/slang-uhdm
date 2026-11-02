// § importCopyTsInstByRole469
// a typedef of an enum typedef: the parameter's chain ends on an enum
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  typedef e_t f_t;
  parameter f_t PF = E2;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
