// § pkgEnumUntypedParamFold401
package p1;
  typedef enum logic [2:0] { A = 3'd1, B = 3'd6 } e_t;
endpackage
package p2;
  parameter m = p1::B;
endpackage
module top; endmodule
