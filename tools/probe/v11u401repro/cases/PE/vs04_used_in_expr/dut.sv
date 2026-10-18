// § pkgEnumParamFold401
package p1;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
package p2;
  parameter p1::e_t m = p1::C;
  parameter int w = m + 1;
  parameter int z = (m == p1::C) ? 4 : 8;
endpackage
module top;
  logic [p2::w-1:0] x;
endmodule
