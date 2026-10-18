// § pkgEnumUntypedParamFold401
package p1;
  typedef enum int unsigned { A = 5, B = 7 } e_t;
endpackage
package p2;
  parameter m = p1::B;
endpackage
module top; endmodule
