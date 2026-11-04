// § genScopeProcPsNamedByScope154
module rs #(parameter SYN = 1) (input clk, input [3:0] x, output [3:0] o);
  reg [3:0] v;
  generate
    if (SYN) begin
      always @(posedge clk) v[2:0] <= x[2:0];
    end
  endgenerate
  assign o = v;
endmodule
module top(input clk, input [3:0] x, output [3:0] o);
  rs r(clk, x, o);
endmodule
