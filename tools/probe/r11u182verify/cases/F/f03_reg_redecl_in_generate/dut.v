// § splitPortTsKeyOnPortDecl171
module dut (clk, x, y, z);
  parameter N = 2;
  input clk;
  output [7:0] x;
  output [7:0] y;
  output z;
  reg signed [7:0] x, y;
  reg z;
  generate
    if (N > 1) begin : g
      always @(posedge clk) begin
        x <= x + 1;
        y <= y - 1;
        z <= ~z;
      end
    end
  endgenerate
endmodule
