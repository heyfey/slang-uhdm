// § unitImpTransLateList459
package pk;
  class C;
    int a2[4]; int dq[$];
    extern function void run();
  endclass
  function void C::run();
    foreach (a2[a]) a2[a] = a;
    foreach (this.dq[b]) dq[b] = b;
  endfunction
endpackage
package x; import pk::*; endpackage
package y; import x::*; endpackage
import y::*;
module top; import y::*; pk::C c; initial begin c = new(); c.run(); end endmodule
