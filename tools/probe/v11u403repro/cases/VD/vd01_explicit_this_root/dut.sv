// § dottedPropRootUnitImport403
package p;
class N; int s[]; endclass
class C;
  N m;
  extern function void f();
endclass
function void C::f();
  foreach (this.m.s[i]) $display(i);
endfunction
endpackage
import p::*;
module top; endmodule
