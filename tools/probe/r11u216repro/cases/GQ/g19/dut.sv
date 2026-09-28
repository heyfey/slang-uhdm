// § genScopeRangeQueryFold216 — $high of a localparam declared inside the gen-for block
module top();
  for (genvar i = 0; i < 2; i++) begin : g
    localparam [5:2] b = 1;
    assign ccc = $high(b);
  end
endmodule
