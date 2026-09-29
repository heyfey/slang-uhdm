// § genScopeRangeQueryFold216 — queries onto a module output variable, a reg output, and a signed module net, in a gen-for
module dut (output logic [2:0] o1, output reg [7:0] o2, output logic signed [7:0] o3);
  logic [6:1] v;
  logic signed [4:-3] sv;
  logic signed [7:0] sn;
  for (genvar i = 0; i < 1; i++) begin : g
    assign o1 = $high(v);
    assign o2 = $low(sv);
    assign sn = $low(sv);
  end
  assign o3 = sn;
endmodule
