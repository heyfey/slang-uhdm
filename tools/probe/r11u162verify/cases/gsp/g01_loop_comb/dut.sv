// § genScopeProcPsNamedByScope154
module rs (input [7:0] x, output [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : gl
    reg [3:0] v;
    always @* v[3:0] = x[i*4 +: 4];
    assign o[i*4 +: 4] = v;
  end
endmodule
module top(input [7:0] x, output [7:0] o); rs r(x, o); endmodule
