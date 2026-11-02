// § pkgTransImpAggTd465
// downstream: a module reads a struct typed through A's own typedef over C's enum (scoped), with logic
package C;
  typedef enum logic [1:0] {C0, C1, C2} e_t;
  typedef struct packed { e_t e; logic [3:0] d; } s_t;
endpackage
package B;
  import C::*;
  s_t bv;
endpackage
package A;
  import B::*;
  typedef struct packed { C::e_t k; logic v; } a_t;
endpackage
module top(input logic [2:0] i, output logic [1:0] o, output logic ov);
  import A::*;
  a_t m;
  assign m = a_t'(i);
  assign o = m.k;
  assign ov = m.v;
endmodule
