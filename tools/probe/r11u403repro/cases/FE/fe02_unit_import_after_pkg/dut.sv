// § foreachUnitImportElemVar403
package p;
class W; function void g(); endfunction endclass
W q[$];
function void f();
  foreach (q[i]) q[i].g();
endfunction
endpackage
import p::*;
