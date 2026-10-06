// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module sha import hp::*; (input clk);
  w_t [1:0] v;
  wire w_t [1:0] n;
  assign n = '0;
endmodule
module top(input clk);
  sha u_s(.clk(clk));
endmodule
