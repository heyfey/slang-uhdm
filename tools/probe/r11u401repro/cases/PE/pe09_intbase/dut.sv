// § pkgEnumParamFold401
package p1;
  typedef enum int { A, B, C } e_t;
endpackage
package p2;
  parameter p1::e_t m = p1::B;
endpackage
module top; endmodule
