// § foreachUnitImportElemVar403
package p;
class W; function void g(); endfunction endclass
W q[$];
class M;
  function void run();
    foreach (q[k]) q[k].g();
  endfunction
endclass
endpackage
import p::*;
module top; endmodule
