// § genScopeRangeQueryFold216 — $low of a binary-literal bound onto a narrower module net (the binary arm truncates)
module top (input logic [3'b110:3'b010] i, output logic [1:0] c);
  if (1) begin : g
    assign c = $low(i);
  end
endmodule
