// § pkgEnumUntypedParamFold401
package p1;
  typedef enum logic [3:0] { A = 4'h3, B = 4'hc } e_t;
endpackage
package p2;
  parameter m = p1::B, n = p1::A;
endpackage
module top; endmodule
