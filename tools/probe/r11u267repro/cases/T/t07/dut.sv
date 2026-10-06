// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module s1 import hp::*; (
`include "w.svh"
  input x);
endmodule
module s2 import hp::*; (
`include "w.svh"
  input y);
endmodule
module top(input [7:0] a);
  s1 u1(.a(a), .x(1'b0));
  s2 u2(.a(a), .y(1'b0));
endmodule
