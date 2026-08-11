// r10uvm47 arm t65c — the VARIABLE-arm / NET-arm CROSS cells of
// § pkgInitRefBindsOwnListing47, plus the SUBROUTINE-hoist cell.
//
// A package data declaration written with a user typedef that resolves to a
// packed vector is a logic_NET, not a variable (§ the r9bpapb split), and the
// two arms live in DIFFERENT output vectors (vpiNet vs vpiVariables).  t65a
// showed golden gives a package net NO initialiser expression at all, so a net
// can never be the REFERRER — but it can still be the REFERENT.  Cells:
//
//   x_from_net   a VARIABLE initialised from a package NET  (`int x = n_first;`)
//   e_from_enum  a VARIABLE initialised from an enum_var (a typedef'd enum is a
//                variable, not a net, so it sits in the same vector)
//   h_hoist      a variable read by an OUT-OF-BODY constructor whose locals
//                Surelog hoists into the package listing (§ collectOobCtorLocals)
//                — the hoisted entries share the vector, so a name-keyed lookup
//                could bind to a HOISTED local instead of the package member,
//                and this cell says whether golden ever does that.
package r1;

  typedef logic [3:0] w4;
  typedef enum { E0, E1 } e_t;

  w4  n_first = 4'h5;
  int x_from_net = n_first;      // x_from_net

  e_t ev_first = E1;
  e_t ev_back  = ev_first;       // e_from_enum

  int shared_name = 1;

  class ooc;
    int p;
    extern function new();
  endclass

  function ooc::new();
    int shared_name = 2;         // h_hoist: a hoisted local of the SAME name
    p = shared_name;
  endfunction

  int reads_shared = shared_name;

endpackage

module t65c;
  import r1::*;
  initial $display("%0d %0d", x_from_net, reads_shared);
endmodule
