// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module sha import hp::*; #(parameter int N = 2) (input w_t [N-1:0] a);
endmodule
module top(input [11:0] a);
  sha #(.N(3)) u_s(.a(a));
endmodule
