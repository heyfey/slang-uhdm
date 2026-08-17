// r10uvm81 VERIFIER arm F — LAW 1's HOME-PACKAGE gate at the edges c8 does not
// reach: a wildcard-imported OTHER package's variable, a class EXTENDED across
// packages, a PARAMETERIZED class, a nested class, an out-of-body method of a
// class whose extern prototype and body live in the same package while the base
// class lives in another, and an explicit (non-wildcard) import.
package pf96;
  int  fv;                       // pf96's OWN variable, name `fv`
  int  shared_v;                 // a name BOTH packages declare
  int  sink;
  class base96;
    int m_a;
    extern function void bset(int fv);          // F-a: own pkg, own var
    extern function void bshared(int shared_v); // F-b: own pkg, shared name
  endclass
  function void base96::bset(int fv);
    m_a = fv;
  endfunction
  function void base96::bshared(int shared_v);
    m_a = shared_v;
  endfunction
  function void pfun96(int fv);
    sink = fv;                                  // F-c: plain pkg fn, own var
  endfunction
endpackage

package pg96;
  import pf96::*;                // WILDCARD import: clones pf96's variables
  int  gv;                       // pg96's OWN variable
  int  shared_v;                 // pg96's OWN `shared_v`, shadowing the clone
  int  sink;

  // F-d: pg96's OWN function, formal named after PF96's variable `fv`
  //      (reachable here only through the wildcard import's CLONE)
  function void gfun_fv(int fv);
    sink = fv;
  endfunction
  // F-e: pg96's OWN function, formal named after pg96's own `gv`
  function void gfun_gv(int gv);
    sink = gv;
  endfunction
  // F-f: pg96's OWN function, formal named after the SHARED name
  function void gfun_shared(int shared_v);
    sink = shared_v;
  endfunction

  // F-g: a class EXTENDING pf96::base96, with its own out-of-body method
  class derived96 extends base96;
    extern function void dset(int gv);
    extern function void dset_fv(int fv);
  endclass
  function void derived96::dset(int gv);
    m_a = gv;
  endfunction
  function void derived96::dset_fv(int fv);
    m_a = fv;
  endfunction
endpackage

// EXPLICIT (non-wildcard) import — no clone of the whole listing
package ph96;
  import pf96::fv;
  int  hv;
  int  sink;
  function void hfun_fv(int fv);      // F-h: explicit-imported name
    sink = fv;
  endfunction
  function void hfun_hv(int hv);      // F-i: ph96's own variable
    sink = hv;
  endfunction
endpackage

// A PARAMETERIZED class and a NESTED class, both in a package
package pi96;
  int pv;
  int sink;
  class pcls96 #(int W = 8);
    int m_a;
    extern function void pset(int pv);          // F-j: parameterized class oob
  endclass
  function void pcls96::pset(int pv);
    m_a = pv;
  endfunction

  class outer96;
    int m_b;
    class inner96;
      int m_c;
      function void iset(int pv);               // F-k: NESTED class, in-body
        m_c = pv;
      endfunction
    endclass
    extern function void oset(int pv);          // F-l: outer class oob
  endclass
  function void outer96::oset(int pv);
    m_b = pv;
  endfunction
endpackage
