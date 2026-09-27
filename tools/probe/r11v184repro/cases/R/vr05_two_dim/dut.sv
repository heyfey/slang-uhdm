// § rootLvalueSpanAtRoot184: a $root target with two selects of an unpacked array
module top; logic [7:0] v; logic [3:0] arr [2][3]; logic [3:0] w; logic clk; sub u(); endmodule
module sub;
  initial $root.top.arr[1][2] = 4'd2;
endmodule
