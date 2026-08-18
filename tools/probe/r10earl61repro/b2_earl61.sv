// r10earl61 GRID E (TARGET B boundary) — the OTHER carriers of a struct
// assignment pattern, so § patFlatUnsizedMemberWidth61's widening is measured
// where it is NOT the cont_assign RHS: a DECLARATION INITIALIZER (the
// structuredPkgPat arm, which deliberately skips adjustOpSize), a PARAMETER, a
// PORT CONNECTION actual, a PROCEDURAL assignment, and an unpacked ARRAY of
// structs.
package pc61;
  typedef struct packed {
    logic [2:0] w3;
    logic       w1;
    logic [7:0] w8;
  } t61_t;
  parameter t61_t PK = '{ w3 : '0, w1 : '1, w8 : '0 };
endpackage

module kb61 (input pc61::t61_t p, output logic y);
  assign y = p.w1;
endmodule

module b2_earl61 (input logic clk, output logic q1, output pc61::t61_t o1);
  import pc61::*;
  // E1: DECLARATION INITIALIZER of a struct signal
  t61_t dv = '{ w3 : '0, w1 : '1, w8 : 'x };
  // E2: module-scope PARAMETER of struct type
  parameter t61_t MP = '{ w3 : '1, w1 : '0, w8 : '0 };
  // E3: unpacked ARRAY of structs, declaration init
  t61_t da [1:0] = '{ '{ w3 : '0, w1 : '0, w8 : '0 },
                      '{ w3 : '1, w1 : '1, w8 : '1 } };
  // E4: PROCEDURAL assignment
  t61_t pv;
  always_comb pv = '{ w3 : '0, w1 : '1, w8 : '0 };
  // E5: PORT CONNECTION actual
  kb61 i_k (.p('{ w3 : '0, w1 : '1, w8 : '0 }), .y(q1));
  // E6: cont_assign to an OUTPUT PORT (the control: the landed shape)
  assign o1 = '{ w3 : '0, w1 : '1, w8 : '0 };
endmodule
