// § pkgOwnEnumQualRefKeepsName401
package p2;
  typedef enum logic [1:0] { A = 2'b01, B = 2'b10 } e_t;
  parameter m = p2::B;
  parameter n = A;
endpackage
module top; endmodule
