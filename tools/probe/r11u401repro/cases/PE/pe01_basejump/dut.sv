// § pkgEnumParamFold401
package p1;
  typedef enum bit [6:0] { A, B, C } e_t;
endpackage
package p2;
  parameter int w = 3;
  parameter p1::e_t m = p1::A;
endpackage
module top; endmodule
