// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
`define PORT(n) input w_t [1:0] n
module sha import hp::*; (`PORT(a), input b);
endmodule
module top(input [7:0] a);
  sha u_s(.a(a), .b(1'b0));
endmodule
