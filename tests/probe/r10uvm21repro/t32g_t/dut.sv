// r10uvm21 t32g -- t32f's body with NO import anywhere (t32a's arm).  The
// control that says which of t32f's answers are the $unit import's doing and
// which are the `this.` / `other.` spelling's own.
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

module top;
  pk::C c;
  initial begin
    c = new();
    c.run(c);
  end
endmodule
