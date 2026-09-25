// § genScopeProcPsNamedByScope154
module rs (input clk, input [3:0] x, output [3:0] o);
  generate
    if (1) begin : a
      reg [3:0] v;
      always_comb begin
        v = '0;
        v[2:0] = x[3:1];
      end
      assign o = v;
    end
  endgenerate
endmodule
module top(input clk, input [3:0] x, output [3:0] o);
  rs r1(clk, x, o);
endmodule
