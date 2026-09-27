// § rootElemAtNextTok186 (if-generate, a two-component path, and outside the scope as control)
module top; logic v; logic z; sub u(); endmodule
module sub;
  logic w, y;
  if (1) begin : g
    assign w = $root.top.v;
  end
  assign y = $root.top.z;
endmodule
