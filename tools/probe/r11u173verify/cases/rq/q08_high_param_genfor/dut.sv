// § rangeQueryFoldUnconverted164 — $high of a parameter onto an implicit net inside a gen-for scope
module top();
  parameter [4:1] a = 3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign ccc = $high(a);
  end
endmodule
