// § dottedPropRootUnitImport403
package p;
class N; int s[]; endclass
class C;
  N m;
  function void f();
    foreach (m.s[i]) $display(i);
  endfunction
endclass
endpackage
import p::*;
module top; endmodule
