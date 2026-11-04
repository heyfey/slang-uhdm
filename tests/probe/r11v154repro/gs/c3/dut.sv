// § genScopeProcPsNamedByScope154
module rs (input clk, input [3:0] x, output [3:0] o);
  generate
    if (1) begin : nb
      reg [3:0] v;
      always @(posedge clk) begin : blk
        v[3:1] <= x[2:0];
      end
      assign o = v;
    end
  endgenerate
endmodule
module top(input clk, input [3:0] x, output [3:0] o);
  rs r(clk, x, o);
endmodule
