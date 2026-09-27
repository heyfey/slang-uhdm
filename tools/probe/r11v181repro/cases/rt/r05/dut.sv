// § rootPathFullNameByChain181 § rootNetPathOwnNames181 (v11u181 break: $root in a generate-for continuous assignment and a gen-if always_ff, a wire target)
module top(input logic clk);
  wire [3:0] w;
  logic [3:0] r;
  for (genvar g = 0; g < 2; g++) begin : G
    logic t;
    assign t = $root.top.w[g];
  end
  if (1) begin : H
    always_ff @(posedge clk) r <= $root.top.w;
  end
endmodule
