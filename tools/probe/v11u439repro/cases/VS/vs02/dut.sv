// § foreachLeadSkipPlaceholder439
package pk;
class C;
  int a[2][3];
  function void f(); foreach (a[, j]) a[0][j] = j; endfunction
endclass
endpackage
module top;
import pk::*;
C h;
initial begin h = new; h.f(); end
endmodule
