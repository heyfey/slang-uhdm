// § pkgEnumParamFold401
package p1;
  typedef enum logic [1:0] { A = 2'b01, B = 2'b10 } e_t;
endpackage
package p2;
  localparam p1::e_t m = p1::B;
endpackage
module top; endmodule
