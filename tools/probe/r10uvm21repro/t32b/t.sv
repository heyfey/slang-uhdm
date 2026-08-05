// r10uvm21 t32b -- t32a's body, home package wildcard-imported INSIDE A MODULE
// (the SeqDriver `module top_tb; import uvm_pkg::*;` position).
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
  import pk::*;
  C c;
  initial begin
    c = new();
    c.run();
  end
endmodule
