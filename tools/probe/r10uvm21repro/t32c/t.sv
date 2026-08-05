// r10uvm21 t32c -- t32a's body, home package wildcard-imported at
// COMPILATION-UNIT ($unit) scope (the SimpleUVM / Scoreboard position:
// `import uvm_pkg::*;` outside any module or package).  THE HYPOTHESIS: this
// arm alone loses the class-property resolution.
package pk;
  class Cel;
    int x;
  endclass

  class C;
    int p_q[$];
    int p_d[];
    int p_f[4];
    string p_a[string];
    Cel p_c[Cel];
    extern task run();
  endclass

  task C::run();
    foreach (p_q[iq]) p_q[iq] = p_q[iq];
    foreach (p_d[id]) p_d[id] = p_d[id];
    foreach (p_f[ixf]) p_f[ixf] = p_f[ixf];
    foreach (p_a[ia]) p_a[ia] = p_a[ia];
    foreach (p_c[ic]) p_c[ic] = p_c[ic];
  endtask
endpackage

import pk::*;

module top;
  C c;
  initial begin
    c = new();
    c.run();
  end
endmodule
