// § rootLvalueSpanAtRoot184: a $root target with a part-select
module top; logic [7:0] v; logic [3:0] arr [2][3]; logic [3:0] w; logic clk; sub u(); endmodule
module sub;
  initial $root.top.v[3:0] = 4'd1;
endmodule
