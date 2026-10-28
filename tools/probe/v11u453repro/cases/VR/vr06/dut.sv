// § vsTrailRangeParenStart453
module top;
  parameter int W = 2;
  logic [3:0][7:0] q;
  logic [1:0] y [2];
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y[g] = q[g][(g+1):(g)];
  end
endmodule
