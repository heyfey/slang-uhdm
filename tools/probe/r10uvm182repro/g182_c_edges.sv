// r10uvm182 arm C — THE ADVERSARIAL EDGES.  Every cell here is a place the
// stated law could be wrong, written so that golden answers it.
//
//  C1  parens-FUL `<queue>.size()` in a clone body.  UHDM's
//      `hier_path::DeepClone` mints the `func_call` BEFORE it looks at the
//      element's kind and only BINDS it through an `any_cast<ref_obj*>`, so a
//      `method_func_call` element leaves the mint UNREFERENCED — a dump-tail
//      object no `Compare` edge can reach.  This cell says out loud whether
//      that orphan exists.
//  C2  a queue whose ELEMENT STRUCT HAS A MEMBER NAMED `size`.  The builtin
//      mint happens in `DeepClone`'s FIRST switch; the struct-member scan sits
//      in the SECOND switch and carries NO `!found` guard, so the member is the
//      LAST writer.  If that reading is right, golden binds the MEMBER here and
//      not the mint.
//  C3  a body LOCAL literally named `size` alongside `<queue>.size`.  There is
//      no name-lookup fallback for a hier_path element in `DeepClone` at all,
//      so the mint must win over the local — the opposite of what our own
//      clone-body name binder would do on its own.
//  C4  a STRUCT MEMBER that is itself a queue: `crate.hoard.size`.  The
//      predecessor is then a `typespec_member`, which reaches `DeepClone`'s
//      typespec_member arm — an arm with NO builtin mint — so this must stay
//      BARE.
//  C5  the same read in a MODULE, which is not a wildcard-import clone at all.
//  C6  the same read in the HOME package's own listing (a function nobody
//      imports), which is likewise not a clone.
package brace182_home;

  typedef struct { int size; int hasp; } tare182_t;   // a member named `size`
  typedef struct { int hoard [$]; int latch; } crib182_t;

  function automatic int c1_parens182_fn();
    int sluice [$];
    int hob;
    hob = sluice.size();                 // C1
    return hob;
  endfunction

  function automatic int c2_member182_fn();
    tare182_t nook [$];
    int       hob;
    hob = nook.size;                     // C2
    return hob;
  endfunction

  function automatic int c3_shadow182_fn();
    int sluice [$];
    int size;
    int hob;
    size = 3;
    hob = sluice.size + size;            // C3
    return hob;
  endfunction

  function automatic int c4_tsmember182_fn();
    crib182_t crate;
    int       hob;
    hob = crate.hoard.size;              // C4
    return hob;
  endfunction

endpackage

package brace182_imp;
  import brace182_home::*;
  int brace182_anchor;
endpackage

module brace182_top;
  // C5 — a module body: never a wildcard-import clone.
  function automatic int c5_mod182_fn();
    int sluice [$];
    int hob;
    hob = sluice.size;                   // C5
    return hob;
  endfunction
  int brace182_sink;
  initial begin
    brace182_sink = c5_mod182_fn();
    brace182_imp::brace182_anchor = 0;
  end
endmodule
