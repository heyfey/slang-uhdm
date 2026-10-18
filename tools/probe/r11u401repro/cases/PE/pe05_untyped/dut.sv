// § pkgEnumParamFold401
package p1;
  typedef enum bit [6:0] { A, B, C } e_t;
endpackage
package p2;
  parameter m = p1::C;
endpackage
module top; endmodule
