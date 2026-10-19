// § foreachUnitImportElemVar403
package p;
class W; function void g(); endfunction endclass
W q[$];
function void f();
  foreach (q[i]) q[i].g();
endfunction
endpackage
package r;
class V; function void g(); endfunction endclass
V q2[$];
function void f2();
  foreach (q2[j]) q2[j].g();
endfunction
endpackage
import p::*;
module top; endmodule
