// § unitImpTransLateList459
package pk;
  class C;
    int p_q[$];
    function int sum(); int s = 0; foreach (p_q[k]) s += p_q[k]; return s; endfunction
  endclass
endpackage
package x; import pk::*; endpackage
import x::*;
module top; pk::C c; int r; initial begin c = new(); r = c.sum(); end endmodule
