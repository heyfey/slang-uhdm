// r10v163 — arm E: the spelling EDGES the content arm does not carry — an
// EMPTY `#()` and a user class whose name collides with the
// registry key Surelog gives a BUILT-IN (`mailbox`), reached with an explicit
// package scope so the reference is unambiguous.  Run WITH built-ins.
// (Mixing ordered and named arguments is ILLEGAL SV — both tools reject it,
//  measured, so no cell spells it.)
//
// LHS is ALWAYS golden(Surelog); RHS is always ours.

package Pk_Edge;
  class CfgEdge;
    int q;
  endclass
  class PairEdge #(type AA = int, type BB = int);
    AA a;
    BB b;
  endclass
  // a USER class named exactly like the built-in Surelog registers BARE.
  class mailbox #(type TT = int);
    TT t;
  endclass
endpackage

import Pk_Edge::*;
class CfgUnitE;
  int q;
endclass

class EdgeUser;
  PairEdge#() e01_empty_args;
  Pk_Edge::mailbox#(CfgUnitE) e04_usermailbox_scoped;
  PairEdge#(CfgUnitE, CfgUnitE) e05_control_two_classes;
endclass

module M_edge_v163;
  EdgeUser u_eu;
endmodule
