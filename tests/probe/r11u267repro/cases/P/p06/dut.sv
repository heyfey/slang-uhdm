// § typedefDimNetDropsDims267
package hp;
  typedef logic [31:0] w_t;
endpackage
module sha import hp::*; (
  input clk_i,
  input        [63:0] ml,
  output w_t digest
);
  assign digest = ml[31:0];
endmodule
module top(input clk, input [63:0] m);
  wire [255:0] d;
  sha u_s(.clk_i(clk), .ml(m), .digest(d[31:0]));
endmodule
