`default_nettype none
module top (clk, b, o);
  input wire clk;
  input wire [31:0] b;
  output reg [31:0] o;
  reg [31:0] p;
  always @(posedge clk)
    begin
      p      = b;
      p[3:0] = b[3:0];
      o      = p;
    end
endmodule
