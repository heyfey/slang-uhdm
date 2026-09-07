// r10vearl117 ADVERSARIAL arm va1_calls117 — THE CALL-SHAPE FACES.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// r10earl117 inherits § patCaGenIdxNeverInUserCallArg112v's USER-CALL fence.
// The implementer measured that fence on the plain shapes (f8(x), $unsigned(x),
// and the two 2-deep nestings).  This arm attacks the SHAPES THE FENCE'S
// ARITHMETIC MIGHT NOT SEE, with different names, a different genvar letter,
// a different width and a different unrolling count:
//
//   n1  a PACKAGE-SCOPED user function call's argument
//   n2  a NAMED-ARGUMENT user call
//   n3  a user call in a TERNARY BRANCH (not the condition)
//   n4  a user call inside a CAST
//   n5  a REPLICATION operand
//   n6  a plain concat (control: must FOLD)
//   n7  user( system( user( sel ) ) ) — THREE deep
//   n8  a system call's argument beside an unrelated user call
//   n9  a STREAMING operator's operand
package vp117;
  typedef struct packed {
    logic [3:0] n1;
    logic [3:0] n2;
    logic [3:0] n3;
    logic [3:0] n4;
  } quad_t;
  typedef struct packed {
    logic [3:0] n5;
    logic [3:0] n6;
    logic [3:0] n7;
    logic [3:0] n8;
  } quadb_t;
  function automatic logic [3:0] pkgfn(input logic [3:0] a);
    return a + 4'h3;
  endfunction
endpackage

module va1_calls117 #(
    parameter int NW = 4
) (
    input  logic [7:0] din,
    output logic [3:0] dout
);
  logic [7:0]     BUS;
  vp117::quad_t   qa [NW];
  vp117::quadb_t  qb [NW];
  logic [3:0]     qc [NW];

  assign BUS = din;

  function automatic logic [3:0] mixfn(input logic [3:0] a);
    return a ^ 4'hA;
  endfunction

  for (genvar j = 0; j < NW; j++) begin : gen_call
    assign qa[j] = '{
      n1: vp117::pkgfn({3'b0, BUS[j]}),              // n1 package-scoped user call
      n2: mixfn(.a({3'b0, BUS[j]})),                 // n2 NAMED argument
      n3: (din[0] ? mixfn({3'b0, BUS[j]}) : 4'h0),   // n3 user call in a branch
      n4: 4'(mixfn({3'b0, BUS[j]}))                  // n4 user call inside a cast
    };
    assign qb[j] = '{
      n5: {2{BUS[j], BUS[j]}},                       // n5 replication operand
      n6: {3'b0, BUS[j]},                            // n6 plain concat (control)
      n7: mixfn($unsigned(mixfn({3'b0, BUS[j]}))),   // n7 three deep
      n8: $unsigned({3'b0, BUS[j]}) ^ mixfn(4'h1)    // n8 system arg + a user call
    };
    assign qc[j] = {<<4{{3'b0, BUS[j]}}};            // n9 streaming operand
  end

  assign dout = qa[0].n1 ^ qb[0].n5 ^ qc[0];
endmodule
