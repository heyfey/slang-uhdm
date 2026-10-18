// § pkgEnumParamFold401
package p1;
  typedef enum logic [2:0] {A, B, C} e_t;
endpackage
package p2;
  import p1::*;
  parameter e_t m = B;
  parameter e_t n = p1::C;
  localparam q = A;
endpackage
module top;
  logic [2:0] x;
  assign x = p2::m;
endmodule
