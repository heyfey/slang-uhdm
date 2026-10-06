// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
  typedef w_t v_t;
endpackage
module sha import hp::*; (input clk_i, input v_t [7:0] digest);
endmodule
module top(input clk);
  wire [31:0] d;
  sha u_s(.clk_i(clk), .digest(d));
endmodule
