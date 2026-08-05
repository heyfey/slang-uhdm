// r10uvm21 t32e -- t32a's body with an EXPLICIT (non-wildcard) $unit-scope
// import of the home package.  Surelog's CompileHelper::importPackage copies
// the whole late-typedef-binding list into the importing scope WITHOUT
// filtering by the named object, so this arm asks whether the clobber the
// t32c arm demonstrates needs a wildcard at all.
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

import pk::C;

module top;
  C c;
  initial begin
    c = new();
    c.run();
  end
endmodule
