// § pkgEnumUntypedParamFold401
package p1;
  typedef enum logic [3:0] {A = 4'h3, B, C = 4'b1010} e_t;
endpackage
package p2;
  parameter m = p1::B;
  parameter n = p1::C;
  parameter p1::e_t t = p1::B;
endpackage
module top;
  logic [3:0] x;
  assign x = p2::m + p2::n + p2::t;
endmodule
