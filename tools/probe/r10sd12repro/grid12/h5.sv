// r10sd12 grid cell h5 — THE ORDER AXIS.  r10sd10's law turns on whether the
// OWNER class was compiled first, and its SCOPED arm additionally on REACH.
// This cell puts an EARLY-sorting owner, a LATE-sorting owner and a `$unit`
// owner side by side at the SAME declarator form, so the element's class is
// read against each answer of the predicate separately.
class au5;                     // a $unit class: registered `work@au5`, which
  typedef int u_t;             // no written scope can spell (r10sd10 `g9`)
endclass

package ph5;

  class zel5;
    int q;
  endclass

  class sel5;
    int q;
  endclass

  class a5;                    // ph5::a5 sorts BEFORE ph5::zuser5
    typedef zel5                     e_t;
    typedef struct packed { int f; } es_t;
  endclass

  class zz5;                   // ph5::zz5 sorts AFTER ph5::zuser5
    typedef sel5 l_t;
  endclass

  class zuser5;
    function void f5();
      a5::e_t   e_q[$];        // scoped, owner EARLY -> r10sd10 Resolved
      a5::es_t  es_q[$];       // scoped struct, owner EARLY -> Resolved
      a5::e_t   e_fx[2];
      zz5::l_t  l_q[$];        // scoped, owner LATE  -> ClassVar
      zz5::l_t  l_fx[2];
      e_q = {};
    endfunction
  endclass

endpackage

module toph5;
  initial begin
    ph5::zuser5 u = new();
    u.f5();
  end
endmodule
