// § genScopeProcPsNamedByScope154
module rs (input clk, input [3:0] x, output [3:0] o);
  generate
    for (genvar g = 0; g < 2; g++) begin : gl
      reg [3:0] v;
      always @(posedge clk) v[2:0] <= x[2:0];
      if (g == 0) begin : in
        reg [3:0] w;
        always @(posedge clk) w[3:1] <= v[3:1];
      end
    end
  endgenerate
  assign o = gl[0].v ^ gl[0].in.w;
endmodule
module top(input clk, input [3:0] x, output [3:0] o);
  rs r(clk, x, o);
endmodule
