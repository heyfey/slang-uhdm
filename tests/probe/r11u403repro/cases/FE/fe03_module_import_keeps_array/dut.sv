// § foreachUnitImportElemVar403
package p;
typedef class W;
W q[$];
function void f();
  foreach (q[i]) begin q[i].g(); end
endfunction
class W; function void g(); endfunction endclass
endpackage
module top; import p::*; endmodule
