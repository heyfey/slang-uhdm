// § foreachUnitImportElemVar403
package p;
class W; function void g(); endfunction endclass
W a[string];
function void f();
  foreach (a[s]) a[s].g();
endfunction
endpackage
import p::*;
module top; endmodule
