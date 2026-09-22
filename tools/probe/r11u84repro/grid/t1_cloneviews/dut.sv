// r11u84 t1 — DOES A WILDCARD-IMPORT CLONE READ THE HOME'S ELABORATED SIGNAL
// IN BOTH VIEWS?  `CompileHelper::importPackage` pushes the HOME package's
// Signal POINTERS into the importing scope's own vector
// (CompileHelper.cpp:182-190, `scope->getSignals().push_back(net)`), and
// `design->getPackage(name)` always answers the ELAB Package (the unelab twin
// is built inside Package's ctor, Package.cpp:42, and never registered).  So
// both views of the importer alias the ELAB home Signal — the one
// ElaborationStep's SIMPLE_TYPEDEF rewrite (ElaborationStep.cpp:1489-1500)
// mutated.  If that is the mechanism, the clone's DEF view must carry the
// ELABORATED vpiNetType AND the ELABORATED kind, on every chain length.
package h1;
  typedef logic [7:0] w1_t;        // one hop, logic
  typedef w1_t        w2_t;        // two hops
  typedef w2_t        w3_t;        // three hops
  typedef reg  [7:0]  r1_t;
  typedef bit  [7:0]  b1_t;
  typedef b1_t        b2_t;        // two hops to a BIT
  typedef enum logic [1:0] {E0,E1} e1_t;
  typedef e1_t        e2_t;
  typedef struct packed { int x; logic y; } s1_t;
  typedef struct packed { logic a; logic b; } g1_t;   // all-logic
  typedef s1_t        s2_t;
  wire  w1_t  n_w1;
  wire  w2_t  n_w2;
  wire  w3_t  n_w3;
  w1_t        v_w1;
  w2_t        v_w2;
  r1_t        v_r1;
  b1_t        v_b1;
  b2_t        v_b2;
  e1_t        v_e1;
  e2_t        v_e2;
  s1_t        v_s1;
  s2_t        v_s2;
  g1_t        v_g1;
endpackage

package h2;
  import h1::*;
  logic [7:0] own2;
endpackage

module dut (output logic [31:0] o);
  import h2::*;
  assign o = {24'd0, own2};
endmodule
