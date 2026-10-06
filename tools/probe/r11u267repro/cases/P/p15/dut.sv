// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module sha import hp::*; (input clk_i, output var w_t [1:0] digest);
  assign digest = '0;
endmodule
module top(input clk);
  wire [7:0] d;
  sha u_s(.clk_i(clk), .digest(d));
endmodule
