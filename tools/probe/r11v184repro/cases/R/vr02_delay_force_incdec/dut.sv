// § rootLvalueSpanAtRoot184: $root targets with an intra-assignment delay, a force/release, an inc/dec and a read control
module top; logic [3:0] v; logic [3:0] w; int n; sub u(); endmodule
module sub;
  logic [3:0] x;
  initial begin
    $root.top.v <= #1 4'd3;
    force $root.top.w = 4'd1;
    release $root.top.w;
    $root.top.n++;
    x = $root.top.v;
    $root.top.v[1] = x[0];
  end
endmodule
