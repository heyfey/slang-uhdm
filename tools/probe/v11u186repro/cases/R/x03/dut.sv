// § rootElemAtNextTok186 (an instance-array path component)
module top; mid m[2](); sub u(); endmodule
module mid; logic q; endmodule
module sub;
  logic w;
  if (1) begin : g
    assign w = $root.top.m[1].q;
  end
endmodule
