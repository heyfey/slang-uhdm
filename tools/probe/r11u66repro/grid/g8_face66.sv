// r11u66 arm g8 — THE TWO NON-topView FACES THAT ALSO ENTER THE FLAT op75
// WALK, so the law reaches them too and they need their own golden cells:
//   * § modDefImportPkgSelFlat60 — the MATERIALIZED IMPORT COPY of a package
//     struct-pattern parameter, typed and flat in the DEFINITION listing when
//     the declaring package's own scope member-selects it;
//   * `ifaceArrayDefFold` — an interface instantiated as an ARRAY, whose
//     DEFINITION view re-reduces the parameter defaults and flat-folds.
// One INT-answering setter (K - 1) and one UINT-answering setter (KU << 1) in
// each, so an AWAY cell at either face would show.
package q8;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } s8_t;
  localparam s8_t SEL = '{a: K - 1, b: KU << 1};
  // the package's OWN scope member-selects it — the pass-60 predicate
  localparam int PICK = SEL.a;
endpackage

interface bus8 #(parameter q8::s8_t CFG = '{a: 6 - 1, b: 12});
  logic [31:0] w;
  assign w = CFG.a;
endinterface

module g8_face66
  import q8::*;
  (output logic [31:0] y0, output logic [31:0] y1, output logic [31:0] y2);
  // the ARRAY interface instance — its DEFINITION view re-reduces the default
  bus8 arr[1:0] ();
  bus8 one ();
  assign y0 = arr[0].w;
  assign y1 = one.w;
  assign y2 = q8::PICK;
endmodule
