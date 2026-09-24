interface itf #(parameter int AW = 16, parameter int BW = 32,
                parameter int VW = BW);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
  logic [VW-1:0] v;
  wire  [AW-1:0] wn;
  localparam int LP = AW + 1;
  logic [LP-1:0] lpm;
  modport mp (input a, b, v);
endinterface
module leaf #(parameter int AW = 16, parameter int BW = 32)(
  input logic clk
);
  logic [AW-1:0] a;
  logic [BW-1:0] b;
endmodule
module recv #(parameter int AW = 5)(input logic clk);
  leaf #(8, 32) larr[3](.clk(clk));
endmodule
module top;
  logic clk;
  recv #(.AW(7)) u (.clk(clk));
endmodule
