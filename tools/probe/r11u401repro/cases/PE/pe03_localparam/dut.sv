// § pkgEnumParamFold401
package p1;
  typedef enum logic [3:0] { A = 4'd5, B, C } e_t;
endpackage
package p2;
  localparam p1::e_t m = p1::B;
endpackage
module top; endmodule
