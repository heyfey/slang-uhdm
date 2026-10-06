// § typedefDimNetDropsDims267
package hp;
  typedef logic [31:0] w_t;
endpackage
module sha import hp::*; (
  input clk_i,
  output w_t [1:0][3:0] digest
);
  
endmodule
module top(input clk, input [63:0] m);
  wire [255:0] d;
  sha u_s(.clk_i(clk), .digest(d));
endmodule
