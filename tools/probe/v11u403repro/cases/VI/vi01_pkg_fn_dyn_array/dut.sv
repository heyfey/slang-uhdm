// § foreachUnitImportElemVar403
package p;
class W; function void g(); endfunction endclass
W d[];
function void f();
  foreach (d[i]) d[i].g();
endfunction
endpackage
import p::*;
module top; endmodule
