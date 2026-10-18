// § pkgEnumParamFold401
package p2;
  localparam p1::e_t m = p1::B;
endpackage
package p1;
  typedef enum logic [1:0] { A = 0, B = 1 } e_t;
endpackage
module top; endmodule
