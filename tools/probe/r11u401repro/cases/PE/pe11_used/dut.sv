// § pkgEnumParamFold401
package p1;
  typedef enum bit [2:0] { A, B, C } e_t;
endpackage
package p2;
  parameter p1::e_t m = p1::C;
  localparam int k = m + 1;
endpackage
module top import p2::*; (output logic [3:0] o);
  assign o = k;
endmodule
