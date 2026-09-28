// § rootLvalueSpanAtRoot184 § rootElemAtNextTok186 § rootNetPathOwnNames181: $root lvalues in a generate-for body's process and a generate-if continuous assignment, beside $root reads in the same scopes
module top;
  logic [3:0] a;
  logic [3:0] b;
  wire [3:0] n;
  sub u ();
endmodule
module sub (input logic clk = 1'b0);
  for (genvar i = 0; i < 2; i++) begin : gl
    always @(posedge clk) $root.top.a[i] <= $root.top.b[i];
  end
  if (1) begin : gi
    assign $root.top.n = $root.top.b;
  end
endmodule
