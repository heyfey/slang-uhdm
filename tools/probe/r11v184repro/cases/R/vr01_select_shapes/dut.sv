// § rootLvalueSpanAtRoot184: $root targets with a part-select, a two-dimensional select, a variable index and an indexed part-select
module top; logic [7:0] v; logic [3:0] arr [2][3]; int i; sub u(); endmodule
module sub;
  initial begin
    $root.top.v[3:0] = 4'd1;
    $root.top.arr[1][2] = 4'd2;
    $root.top.v[$root.top.i] = 1'b1;
    $root.top.v[$root.top.i +: 2] = 2'b10;
    $root.top.arr[0][1][2] = 1'b1;
  end
endmodule
