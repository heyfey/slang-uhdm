// § unitImpTransLateList459
package pk;
  class C;
    int p_q[$]; int p_d[];
    task run();
      foreach (p_q[iq]) p_q[iq] = p_q[iq];
      foreach (p_d[id]) p_d[id] = p_d[id];
    endtask
  endclass
endpackage
package x; import pk::*; endpackage
import x::*;
module top; pk::C c; initial begin c = new(); c.run(); end endmodule
