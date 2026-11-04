// § genScopeProcPsNamedByScope154
module rs (input en, input [3:0] x, output [3:0] o);
  if (1) begin : gl
    reg [3:0] v;
    always_latch if (en) v[3:2] = x[1:0];
    assign o = v;
  end
endmodule
module top(input en, input [3:0] x, output [3:0] o); rs r(en, x, o); endmodule
