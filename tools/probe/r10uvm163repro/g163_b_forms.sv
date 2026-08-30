// r10uvm163 / arm B — the DECLARATION FORMS, put to the home relation arm A
// decided: a PACKAGE generic named UNQUALIFIED from a declaring scope
// Surelog's three `getClassDefinition` probes cannot spell.  Same-home
// controls (`kN_*`) sit beside every firing cell (`bN_*`) so an arm that
// AGREES can be told from an arm that TESTS.
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.  Cell names are the
// variable names.

package gamma163;
  class cfgGa163;
    int qq;
  endclass
  class genGa163 #(type TA = int, type TB = int);
    TA aa;
    TB bb;
  endclass

  // ---- the SAME-HOME controls: probe 3 spells `gamma163::genGa163`, HITS,
  // and golden gives these NO listing.  They must not move.
  class ctrlGa163;
    genGa163#(cfgGa163) k1_samehome_prop;
    static genGa163#(cfgGa163) k2_samehome_static;
    local genGa163#(cfgGa163) k3_samehome_local;
    function void m163();
      genGa163#(cfgGa163) k4_samehome_methodlocal;
      k4_samehome_methodlocal = null;
    endfunction
  endclass

  // k5: a PACKAGE VARIABLE of this package's OWN generic
  genGa163#(cfgGa163) k5_samehome_pkgvar;
endpackage

// ---------------------------------------------------------------------------
package delta163;
  import gamma163::*;
  class cfgDe163;
    int qq;
  endclass

  // b1..b9: a class in ANOTHER package holding gamma163's generic.
  class holdDe163;
    genGa163#(cfgDe163) b1_prop;                   // a plain property
    static genGa163#(cfgDe163) b2_static;          // a STATIC property
    local genGa163#(cfgDe163) b3_local;            // a LOCAL property
    protected genGa163#(cfgDe163) b4_protected;    // a PROTECTED property
    rand genGa163#(cfgDe163) b5_rand;              // a RAND property
    genGa163#(cfgDe163) b6_fixed[3];               // a FIXED unpacked array
    genGa163#(cfgDe163) b7_queue[$];               // a QUEUE
    genGa163#(cfgDe163) b8_dyn[];                  // a DYNAMIC array
    function void n163();
      genGa163#(cfgDe163) b9_methodlocal;          // a METHOD LOCAL
      b9_methodlocal = null;
    endfunction
    // b11: a BUILT-IN generic.  Surelog registers `mailbox` / `semaphore` /
    // `process` under their SHORT name (Builtin.cpp:385-392), so the FIRST
    // probe hits from anywhere and golden gives them NO listing wherever they
    // are written; slang puts them in a synthesized `std` PACKAGE, which would
    // read as a foreign-home package generic without the fence.  This is the
    // corpus cell `mailbox #(T) m;` at uvm-1.2 uvm_tlm_fifo.svh:50 in shape.
    mailbox#(cfgDe163) b11_builtin_mailbox;
    semaphore b12_builtin_semaphore;
  endclass

  // b10: a PACKAGE VARIABLE of a FOREIGN package's generic
  genGa163#(cfgDe163) b10_pkgvar;
endpackage

// ---------------------------------------------------------------------------
module topB163;
  // k6/k7: MODULE variables — r10uvm53's `!declInInstance53` fences these and
  // golden splits them on the INITIALIZER, not on the home; they must NOT move.
  gamma163::genGa163#(gamma163::cfgGa163) k6_modvar;
  gamma163::genGa163#(gamma163::cfgGa163) k7_modvar_new = new;

  delta163::holdDe163 hd;
  gamma163::ctrlGa163 cg;
endmodule
