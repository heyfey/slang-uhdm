// § pkgEnumParamFold401
package p2;
  parameter p1::e_t m = p1::B;
endpackage
package p1;
  typedef enum bit [6:0] { A, B, C } e_t;
endpackage
module top; endmodule
