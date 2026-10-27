// § foreachTrailSkipDropped439
module top;
class C;
  int a[2][3];
  function void f(); foreach (a[i, ]) a[i][0] = i; endfunction
endclass
C h;
initial begin h = new; h.f(); end
endmodule
