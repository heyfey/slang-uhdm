// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module sha import hp::*; (input w_t [1:0] a);
endmodule
module top(input [7:0] a);
  sha u_s(.a(a));
endmodule
