// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module sha import hp::*; (input logic [15:0] i, output wand b_t [1:0] o, output tri b_t [1:0] t);
  assign o = i;
  assign t = i;
endmodule
module top(input logic [15:0] i, output wire [15:0] o, output wire [15:0] t);
  sha u_s(.i(i), .o(o), .t(t));
endmodule
