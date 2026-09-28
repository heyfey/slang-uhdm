// § rootElemAtNextTok186 § rootLvalueSpanAtRoot184: a $root path with a select read in a generate-scope continuous assignment, and a $root lvalue in the same scope's process
module top;
  logic [7:0] q;
  logic [7:0] t;
  sub u ();
endmodule
module sub (input logic clk = 1'b0);
  logic [3:0] w;
  if (1) begin : g
    assign w = $root.top.q[3:0];
    always @(posedge clk) $root.top.t[1] <= w[0];
  end
endmodule
