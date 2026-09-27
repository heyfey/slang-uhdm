// § procLvPartSelBoundCallName181v § procLvIdxCallWholeSpan181 (r11u190: calls WITH ARGUMENTS as part-select bounds, an indexed part-select base and a bit index in procedural lvalues)
module top;
  logic [15:0] a;
  int k;
  function automatic int f(int x, int y); return x + y; endfunction
  initial begin
    a[f(3, 1):f(0, 0)] = 5'h1;
    a[f(2, k)+:2] = 2'b1;
    a[f(9, 1)] = 1'b1;
    a[f(15, 0)-:4] = 4'hF;
  end
endmodule
