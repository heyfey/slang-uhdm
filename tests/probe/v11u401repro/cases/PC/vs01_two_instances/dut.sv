// § procCheckerIsCheckerInst401
checker chk(logic a, logic b);
  assert property (@(posedge a) b);
endchecker
module top;
  logic clk, x, y;
  always @(posedge clk) begin
    chk c1(x, y);
    x <= y;
  end
endmodule
