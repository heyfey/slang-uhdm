// § rootElemAtNextTok186 (a select on the last component, a for-generate scope)
module top; logic [3:0] v; sub u(); endmodule
module sub;
  logic w;
  for (genvar i = 0; i < 1; i++) begin : g
    assign w = $root.top.v[2];
  end
endmodule
