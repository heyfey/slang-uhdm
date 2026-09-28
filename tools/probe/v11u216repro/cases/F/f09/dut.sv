// § genScopeRangeQueryFold216 — $high of a loop-body localparam with a range in a gen-for
module top (output logic [7:0] c);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam logic [5:2] L = 3;
    wire [7:0] cc;
    assign cc = $high(L);
  end
  assign c = g[0].cc;
endmodule
