// § rootLvalueSpanAtRoot184: a $root target in a generate scope's process, and an indexed one
module top; logic [7:0] v; logic [3:0] arr [2][3]; logic [3:0] w; logic clk; sub u(); endmodule
module sub #(parameter bit P = 1);
  logic [3:0] x;
  if (P) begin : g
    always @(posedge x[0]) begin
      $root.top.w <= x;
      $root.top.w[2] <= 1'b0;
    end
  end
endmodule
