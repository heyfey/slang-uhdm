// r10svs10 arm c3 — the remaining grid axes, once c1/c2 had refuted scope,
// top-ness and assignment-as-such: (a) ASSIGNMENT FORMS the producer's visitor
// may or may not see, (c) the CLASS KIND, (d) TYPEDEF'd class types outside a
// non-ANSI header, (f) MULTIPLE DECLARATORS one assigned one not, (h) ESCAPED
// names.  Every module here has NO header, so `namedTypeNet` never fires and
// the ONLY rule under test is the class-handle written-strip.
package pq;
  class QK; int z; endclass
endpackage

class K;   int x; function new(int v = 0); x = v; endfunction endclass
class P #(parameter int W = 1); int y; endclass
class D extends K;  int d; endclass
virtual class V;    int v; endclass
interface class IC; pure virtual function void f(); endclass
class Impl implements IC; virtual function void f(); endfunction endclass

typedef K K_t;
typedef P#(3) P3_t;

// ---- m: ASSIGNMENT FORMS (axis a) ----
module m_forms;
  K n1;   // n1 assigned in an `initial`            (the visitor sees it)
  K n2;   // n2 assigned in an `always`             (a ProceduralBlock too)
  K n3;   // n3 assigned inside a TASK body         (NOT a ProceduralBlock)
  K n4;   // n4 assigned inside a FUNCTION body     (NOT a ProceduralBlock)
  K n5;   // n5 passed as an OUTPUT argument        (a write, not an assignment)
  K n6;   // n6 assigned from ANOTHER HANDLE
  K n7;   // n7 only READ (appears on a RHS)        (never written)
  K n8;   // n8 written FROM n7                     (a handle-to-handle write)
  K n9 = new();  // n9 DECLARATION INITIALIZER
  K n10;  // n10 never mentioned at all             (control)
  task automatic t3(); n3 = new(); endtask
  function automatic void f4(); n4 = new(); endfunction
  task automatic mk(output K h); h = new(); endtask
  initial begin
    n1 = new();
    mk(n5);
    n6 = n1;
    n8 = n7;
  end
  always @(*) n2 = new();
endmodule

// ---- p: CLASS KIND (axis c) + TYPEDEF (axis d), each ASSIGNED ----
module p_kinds;
  K       q1;   // q1 plain,               ASSIGNED
  P#(2)   q2;   // q2 parameterized,       ASSIGNED
  D       q3;   // q3 derived,             ASSIGNED
  V       q4;   // q4 VIRTUAL class handle, ASSIGNED (from a derived object)
  IC      q5;   // q5 INTERFACE class,     ASSIGNED
  K_t     q6;   // q6 typedef'd,           ASSIGNED (no non-ANSI header here)
  P3_t    q7;   // q7 typedef'd parameterized, ASSIGNED
  pq::QK  q8;   // q8 SCOPED name,         ASSIGNED (the existing carve-out)
  Impl    q9;   // q9 implementing class,  ASSIGNED
  initial begin
    q1 = new(); q2 = new(); q3 = new(); q5 = q9;
    q6 = new(); q7 = new(); q8 = new(); q9 = new();
    q4 = q4;
  end
endmodule

// ---- r: MULTIPLE DECLARATORS (axis f) + ESCAPED names (axis h) ----
module r_decls;
  K r1, r2, r3;         // ONE declaration, THREE declarators: r1 assigned,
                        // r2 assigned, r3 NEVER — does the strip travel the
                        // whole declaration or just the written declarator?
  K \esc.one , \esc.two ;  // escaped: first ASSIGNED, second never
  initial begin
    r1 = new();
    r2 = new();
    \esc.one = new();
  end
endmodule

module top_c3;
  m_forms u_m();
  p_kinds u_p();
  r_decls u_r();
endmodule
