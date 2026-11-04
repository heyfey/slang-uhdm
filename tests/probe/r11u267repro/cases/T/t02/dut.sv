// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module sha import hp::*; (input w_t [1:0] a, input w_t [2:0] b);
endmodule
module top(input [7:0] a, input [11:0] b);
  sha u_s(a, b);
endmodule
