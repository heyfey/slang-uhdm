// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module sha import hp::*; (input clk_i, output logic [31:0] o);
  wire w_t [7:0] x;
  assign o = x;
endmodule
module top(input clk, output logic [31:0] o);
  sha u_s(.clk_i(clk), .o(o));
endmodule
