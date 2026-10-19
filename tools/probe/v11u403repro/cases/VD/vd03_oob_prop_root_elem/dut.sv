// § dottedPropRootUnitImport403
package p;
class N; int s[]; endclass
class C;
  N m[2];
  extern function void f();
endclass
function void C::f();
  foreach (m[0].s[i]) $display(i);
endfunction
endpackage
import p::*;
module top; endmodule
