// § foreachLeadSkipPlaceholder439
class C;
  int arr2[2][3];
  function void f(); foreach (arr2[, j]) arr2[0][j] = j; endfunction
endclass
module top; C c = new; endmodule
