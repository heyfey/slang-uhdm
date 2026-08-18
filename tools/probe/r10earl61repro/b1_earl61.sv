// r10earl61 GRID D (TARGET B) — the ELABORATED assignment-pattern member VALUE
// re-typing.  Surelog's UHDM::ExprEval::flattenPatternAssignments re-types a
// tagged_pattern member whose Pattern() is an UNSIZED constant (VpiSize == -1)
// whose value is 0 or 1, to the MEMBER's width as UINT/vpiUIntConst.  This arm
// varies the member value over every spelling the law could touch.
package pb61;
  typedef struct packed {
    logic [2:0] w3;
    logic       w1;
    logic [7:0] w8;
    logic [15:0] w16;
  } s61_t;
  typedef struct packed { logic [3:0] a; logic [1:0] b; } inner61_t;
  typedef struct packed { logic [2:0] p; inner61_t q; } outer61_t;
endpackage

module b1_earl61 (input logic clk, input logic [7:0] d, output pb61::s61_t o1,
                  output pb61::s61_t o2, output pb61::s61_t o3,
                  output pb61::outer61_t o4, output pb61::s61_t o5);
  import pb61::*;
  logic       v1;
  logic [2:0] v3;
  logic [7:0] v8;

  // D1: every member an UNSIZED '0  (the corpus shape)
  assign o1 = '{ w3 : '0, w1 : '0, w8 : '0, w16 : '0 };

  // D2: unsized '1, unsized 'x, a SIZED literal, and a bare decimal
  assign o2 = '{ w3 : '1, w1 : 'x, w8 : 8'h00, w16 : 0 };

  // D3: MIXED — a ref, an operation, a ternary whose arms are '0, and a
  //     direct '0 AFTER a non-constant member (the corpus's d_param shape)
  assign o3 = '{ w3 : v3, w1 : v1 & clk, w8 : (clk) ? v8 : '0, w16 : '0 };

  // D4: NESTED pattern member, and an unsized '0 next to it
  assign o4 = '{ p : '0, q : '{ a : '0, b : '1 } };

  // D5: a `default:` fill next to a NAMED unsized value (the landed
  //     § patFlatDefaultFillMemberWidth27 half + the new half in one pattern)
  assign o5 = '{ w3 : '1, default : '0 };
endmodule
