// § foreachTrailSkipDropped439
class C;
  int arr3[2][3][4];
  function void f(); foreach (arr3[i, j, ]) arr3[i][j][0] = i + j; endfunction
endclass
module top; C c = new; endmodule
