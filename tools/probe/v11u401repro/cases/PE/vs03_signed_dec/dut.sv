// § pkgEnumUntypedParamFold401
package p1;
  typedef enum int {A = 5, B = 32'sd7, C = 'd9, D} e_t;
endpackage
package p2;
  parameter a = p1::A;
  parameter b = p1::B;
  parameter c = p1::C;
  parameter d = p1::D;
endpackage
module top;
  int x;
  assign x = p2::a + p2::b + p2::c + p2::d;
endmodule
