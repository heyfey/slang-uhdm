// § genScopeRangeQueryFold216 + § ndaRangeQueryFold216 — one INT bound read by a generate query and a net initializer of different widths
module dut #(parameter int W = 6) (input logic [W-1:0] i, output logic [7:0] o, output logic [3:0] c);
  wire [7:0] w = $high(i);
  if (1) begin : g
    assign c = $high(i);
  end
  assign o = w;
endmodule
