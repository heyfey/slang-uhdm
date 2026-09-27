// § rootElemAtNextTok186 (a for-generate scope)
module top; logic [3:0] v; sub u(); endmodule
module sub;
  logic [3:0] w;
  for (genvar i = 0; i < 1; i++) begin : g
    assign w = $root.top.v;
  end
endmodule
