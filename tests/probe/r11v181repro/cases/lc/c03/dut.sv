// § procLvPartSelBoundCallName181v § procLvIdxCallWholeSpan181 (v11u181 break, fixed: a call as a part-select bound, an indexed part-select base, a 2-D index and an associative key in procedural lvalues)
module top;
  logic [15:0] a;
  logic [3:0] m [0:3][0:3];
  int aa[int];
  function automatic int f(int x); return x; endfunction
  initial begin
    a[f(3):f(0)] = 4'h1;
    a[f(4) +: 4] = 4'h2;
    m[f(1)][f(2)] = 4'h3;
    aa[f(5)] = 7;
  end
endmodule
