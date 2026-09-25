// § genScopeProcPsNamedByScope154
module rs (input clk, input [3:0] x, output [3:0] o);
  generate
    if (1) begin : a
      if (1) begin : b
        reg [3:0] v;
        always @(posedge clk) v[2:0] <= x[3:1];
        assign o = v;
      end
    end
  endgenerate
endmodule
module top(input clk, input [3:0] x, output [3:0] o);
  rs r(clk, x, o);
endmodule
