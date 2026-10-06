// § typedefDimNetDropsDims267
package hp;
  typedef logic [31:0] w_t;
endpackage
module sha import hp::*; (
  input clk_i,
  output logic [63:0] ml,
  output w_t [7:0] digest
);
  
endmodule
module top(input clk, input [63:0] m);
  wire [255:0] d;
  sha u_s(.clk_i(clk), .ml(), .digest(d));
endmodule
