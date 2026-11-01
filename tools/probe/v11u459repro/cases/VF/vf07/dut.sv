// § unitImpTransLateList459
package pk;
  class Cel; int x; endclass
  class C;
    int p_q[$]; int p_d[]; string p_a[string];
    extern task run();
  endclass
  task C::run();
    foreach (p_q[iq]) p_q[iq] = p_q[iq];
    foreach (p_d[id]) p_d[id] = p_d[id];
    foreach (p_a[ia]) p_a[ia] = p_a[ia];
  endtask
endpackage
package y; import pk::*; endpackage
package x; import y::*; endpackage
package z; import x::*; endpackage
import z::*;
module top; pk::C c; initial begin c = new(); c.run(); end endmodule
