// § foreachLeadSkipPlaceholder439
class C;
  int arr4[2][3][4][5];
  function void f(); foreach (arr4[, j, , m]) arr4[0][j][0][m] = j + m; endfunction
endclass
module top; C c = new; endmodule
