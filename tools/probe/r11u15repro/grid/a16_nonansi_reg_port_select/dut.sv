`default_nettype none
module top (clk, b, o);
  input wire clk;
  input wire [31:0] b;
  output reg [31:0] o;
  always @(posedge clk)
    begin
      o      = b;
      o[3:0] = b[3:0];
    end
endmodule
