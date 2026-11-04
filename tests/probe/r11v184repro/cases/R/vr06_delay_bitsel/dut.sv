// § rootLvalueSpanAtRoot184: a $root target with an intra-assignment delay, and a bit-select target read from a local
module top; logic [7:0] v; logic [3:0] arr [2][3]; logic [3:0] w; logic clk; sub u(); endmodule
module sub;
  logic [3:0] x;
  initial begin
    $root.top.v <= #1 8'd3;
    $root.top.v[1] = x[0];
  end
endmodule
