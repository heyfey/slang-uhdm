// vsd11 v9 — MULTI-SEGMENT class paths and GENERIC GROUPING.
// (a) `Outer::Inner::td` — three segments, every intermediate a class.  Both
//     `scopedTdSegs11` and the `Owner::` prefix span have to agree with golden
//     on where the LAST segment starts.
// (b) question (4): two specialisations of one generic share ONE claim.  Here
//     the two specialisations are made in DIFFERENT containers so the losing
//     side is decided by the container half of the key.
package pv9;

  class zel9;
    int q;
  endclass

  class aout9;
    class ainn9;
      typedef zel9 deep_t;        // (4, "pv9::aout9::ainn9", "deep_t")
      typedef int  deep_int_t;    // in-place target, always resolves
    endclass
    typedef zel9 out_t;           // (4, "pv9::aout9", "out_t") — sorts first
  endclass

  class ag9 #(type T = int);
    typedef zel9 g_t;             // one claim shared by every specialisation
  endclass

  class buse9;
    ag9#(int)  s_int;
    ag9#(byte) s_byte;
    function void f9();
      aout9::out_t        v_out;      // claimant
      aout9::ainn9::deep_t v_deep;    // MULTI-SEGMENT, loser
      aout9::ainn9::deep_int_t v_di;  // MULTI-SEGMENT, in-place target
      v_out = null;
      v_deep = null;
    endfunction
  endclass

endpackage

module topv9;
  initial begin
    pv9::buse9 b = new();
    b.f9();
  end
endmodule
