// § pkgOwnEnumQualRefKeepsName401
package p2;
  typedef enum bit [6:0] { A, B, C } e_t;
  parameter e_t m = B;
  parameter e_t n = p2::C;
endpackage
module top; endmodule
