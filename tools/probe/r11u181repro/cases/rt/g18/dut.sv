// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path in a generate-for scope's always block
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w [2];
  for (genvar k = 0; k < 2; k++) begin : G always_comb w[k] = $root.top.v; end
endmodule
