// § genScopeRangeQueryFold216 — $high of a ranged parameter onto an implicit net in a gen-for (r11u173 q08)
module top();
  parameter [4:1] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign ccc = $high(a);
  end
endmodule
