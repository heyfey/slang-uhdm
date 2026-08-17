// r10sd11 grid cell g3 — THE SITE AXIS and THE SPAN.
//
// The SAME typedef (`zholdc3::c_t`, a typedef of a class NAME that is the ONLY
// typedef naming `zelem3` and therefore CLAIMS its slot) is written at every
// declaration site the emitter has a separate factory for.  Every one of them
// must RESOLVE — this is the cell that keeps the new predicate from firing on
// a claiming typedef, and the cell that scores the FORMAL site's older
// claim-blind predicate (§ classScopedTdFormalUnsupported34, residue R1).
package px3;
  // ORDERING NOTE.  slang refuses `Owner::td` when `Owner` is only
  // forward-declared, so every owner class is written BEFORE its user and the
  // USER class is written LAST.  That costs the cell nothing: Surelog's class
  // pass is LEXICOGRAPHIC (r10sd10 `g8`), and this law's claim order is read
  // off NAMES too, so `auser*` still sorts first and every `z*` owner still
  // sorts after it.

  class zelem3;
    int q;
  endclass

  class zholdc3;
    typedef zelem3 c_t;
  endclass

  class auser3;
    // (a) RETURN type
    function zholdc3::c_t r_scoped();
      zholdc3::c_t rv;
      return rv;
    endfunction
    // (b) FORMAL, no direction  (c) FORMAL, ref  (d) FORMAL, input keyword
    function void f_args(zholdc3::c_t p_plain, ref zholdc3::c_t p_ref,
                         input zholdc3::c_t p_in);
    endfunction
    // (e) BODY local, no init  (f) BODY local WITH init
    function void f_locals();
      zholdc3::c_t l_bare;
      zholdc3::c_t l_init = null;
      // (g) BLOCK-item local, inside a named begin
      begin : blk3
        zholdc3::c_t l_blk;
        l_blk = null;
      end
      // (h) an unpacked-array declarator on the same typedef
      begin
        zholdc3::c_t l_arr[int];
        l_arr[0] = null;
      end
    endfunction
    // (i) a TASK body local
    task t_locals();
      zholdc3::c_t t_l;
    endtask
    // (j) a class PROPERTY written with the same type
    zholdc3::c_t prop_p;
    zholdc3::c_t prop_a[string];
  endclass

endpackage

module top3;
  initial begin
    px3::auser3 u = new();
    u.f_locals();
  end
endmodule
