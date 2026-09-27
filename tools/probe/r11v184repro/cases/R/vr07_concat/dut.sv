// § rootLvalueSpanAtRoot184: a $root target inside an lvalue concatenation
module top; logic [7:0] v; logic [3:0] arr [2][3]; logic [3:0] w; logic clk; sub u(); endmodule
module sub;
  logic [1:0] y;
  initial {$root.top.w, y} = 6'h15;
endmodule
