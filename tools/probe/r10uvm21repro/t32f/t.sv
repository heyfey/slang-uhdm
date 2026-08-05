// r10uvm21 t32f -- t32c ($unit-scope wildcard import, the arm that resolves
// NOTHING) with every iterated reference written `this.<prop>` instead of the
// bare name, plus a dotted OTHER-OBJECT path for contrast.  uvm-1.2 writes both
// spellings (`foreach (this.in_use[i])` in uvm_mem_mam, `foreach
// (phase.m_predecessors[pred])` in uvm_phase) and golden answers them
// differently under a $unit import, so this arm pins which prefix survives.
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
    extern task run(C other);
  endclass

  task C::run(C other);
    foreach (this.p_q[iq]) this.p_q[iq] = this.p_q[iq];
    foreach (this.p_d[id]) this.p_d[id] = this.p_d[id];
    foreach (this.p_f[ixf]) this.p_f[ixf] = this.p_f[ixf];
    foreach (this.p_a[ia]) this.p_a[ia] = this.p_a[ia];
    foreach (this.p_c[ic]) this.p_c[ic] = this.p_c[ic];
    foreach (other.p_q[oq]) other.p_q[oq] = other.p_q[oq];
    foreach (other.p_a[oa]) other.p_a[oa] = other.p_a[oa];
    foreach (other.p_c[oc]) other.p_c[oc] = other.p_c[oc];
  endtask
endpackage

import pk::*;

module top;
  C c;
  initial begin
    c = new();
    c.run(c);
  end
endmodule
