// r10uvm203 grid arm F — the ONE MEASURED EXCEPTION, isolated.  Four QUEUES
// whose elements are a packed STRUCT typedef, a packed UNION typedef, an int
// typedef and a class typedef.  Golden's module DEF view lists all four as
// nets typed by the element; its ELABORATED view lists three and NOT the
// packed-struct one.  (The shape was found on r10buvm25repro/g25.sv, where it
// was the boundary gate's only two AWAY-GOLDEN cells; this arm exists so the
// exception is measured by a golden of its own rather than by a bystander.)
package pf203;
  typedef struct packed { logic [3:0] x; }               Sf203;
  typedef union  packed { logic [3:0] x; logic [3:0] y; } Uf203;
  typedef int                                             If203;
  class Cf203;
    int v;
  endclass
  typedef Cf203 Kf203;

  Sf203 f_q_struct [$];
  Uf203 f_q_union  [$];
  If203 f_q_int    [$];
  Kf203 f_q_class  [$];
  Cf203 f_q_plain  [$];    // an UNTYPEDEF'd class element: the control
  int   f_plain = 4;
endpackage

import pf203::*;

module gf203;
  bit clk;
endmodule
