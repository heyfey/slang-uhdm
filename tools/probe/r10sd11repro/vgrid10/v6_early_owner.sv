// vsd10 adversarial cell v6 — THE BREAK HUNT.  Every shape where the predicate
// falls back but Surelog's REAL order says the owner WAS already compiled:
//   * a PARAMETERIZED owner that sorts EARLY (`aparm6` < `zuser6`)
//   * an EARLY-sorting base in ANOTHER package, inherited BARE and written
//     SCOPED  (the law's own residue R6, in the direction that breaks)
//   * a package-scope function whose RETURN type is a class-nested typedef
package abase6;
  class abase;
    typedef struct { int a; } b_t;
  endclass
endpackage

package px6;

  class aparm6 #(type T = int);
    typedef struct { int p; } prec_t;
  endclass

  class aplain6;
    typedef struct { int q; } qrec_t;
  endclass

  class zuser6 extends abase6::abase;
    function void f();
      aparm6#(int)::prec_t  v_early_parm;   // EARLY parameterized owner
      aplain6::qrec_t       v_early_plain;  // EARLY plain sibling (control)
      b_t                   v_inh_bare;     // EARLY base, ANOTHER package, bare
      abase6::abase::b_t    v_inh_scoped;   // ... and written SCOPED
      v_early_parm.p  = 1;
      v_early_plain.q = 2;
      v_inh_bare.a    = 3;
      v_inh_scoped.a  = 4;
    endfunction
  endclass

  // PACKAGE-scope function: no enclosing class at all, both spellings
  function automatic aplain6::qrec_t pkgret6();
    pkgret6.q = 1;
  endfunction

endpackage

module top6;
  px6::zuser6 u;
  initial begin u = new(); void'(px6::pkgret6()); end
endmodule
