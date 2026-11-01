// § unitImpTransLateList459
package pk;
  class C;
    string s_q[$]; string s_d[];
    extern function void run();
  endclass
  function void C::run();
    foreach (s_q[a]) s_q[a] = "x";
    foreach (s_d[b]) s_d[b] = "y";
  endfunction
endpackage
package x; import pk::*; endpackage
import x::*;
module top; import x::*; pk::C c; initial begin c = new(); c.run(); end endmodule
