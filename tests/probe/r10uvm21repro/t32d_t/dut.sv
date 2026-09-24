// r10uvm21 t32d -- t32a's body, home package wildcard-imported by ANOTHER
// PACKAGE (the SeqDriver `package adpcm_pkg; import uvm_pkg::*;` position --
// the gate § foreachAssocIdxImporterView19 currently tests).
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

package pk2;
  import pk::*;
  class D extends C;
    int extra;
  endclass
endpackage

module top;
  pk2::D d;
  initial begin
    d = new();
    d.run();
  end
endmodule
