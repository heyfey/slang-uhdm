// § pkgOwnEnumQualRefKeepsName401
package p2;
  typedef enum logic [1:0] { A, B } e_t;
  parameter e_t n = p2::B;
endpackage
module top; endmodule
