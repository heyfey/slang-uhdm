// § unitImpTransLateList459
package pk;
  class Cel; int x; endclass
  class C;
    int p_q[$]; int p_d[]; string p_a[string]; Cel p_c[Cel];
    extern task run();
  endclass
  task C::run();
    foreach (p_q[iq]) p_q[iq] = p_q[iq];
    foreach (p_d[id]) p_d[id] = p_d[id];
    foreach (p_a[ia]) p_a[ia] = p_a[ia];
    foreach (p_c[ic]) p_c[ic] = p_c[ic];
  endtask
endpackage
package x; import pk::*; endpackage
import pk::*;
module top; pk::C c; initial begin c = new(); c.run(); end endmodule
