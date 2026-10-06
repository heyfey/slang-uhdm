// § typedefDimNetDropsDims267
package hp;
  typedef logic signed [3:0] w_t;
endpackage
module sha import hp::*; (input w_t [1:0] a, input wire w_t [1:0] b);
endmodule
module top(input [7:0] a, b);
  sha u_s(.a(a), .b(b));
endmodule
