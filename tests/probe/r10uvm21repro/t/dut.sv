// r10uvm21 t32a -- CLASS-PROPERTY foreach, EXTERN method with an OUT-OF-BODY
// definition at package scope (the uvm-1.2 shape: uvm_factory.svh declares
// `extern function void set_type_override_by_type(...)` and defines it later at
// package scope, which is why the def-package listing names the body
// `uvm_default_factory::set_type_override_by_type`).  NO import of the class's
// home package anywhere -- the control arm of the import-position matrix
// t32a..t32e.  All arms share this body verbatim; only the import moves.
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

module top;
  pk::C c;
  initial begin
    c = new();
    c.run();
  end
endmodule
