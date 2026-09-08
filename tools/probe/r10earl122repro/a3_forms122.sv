// r10earl122 arm a3_forms122 — THE DECLARATION-FORM GRID for a gen scope's own
// LISTING, so §3's net-vs-var SPLIT is a MEASUREMENT and not a citation.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The head this pass cleared was first framed as a LISTING head ("golden lists
// the declared-and-continuously-assigned gen-local under the scope's variables
// where we list none").  `own122` refuted that at the head's own scope and §3
// refutes it over the whole Earlgrey design; this arm is the FORM axis of the
// same question: one gen-block local per declaration form, so what each form
// lands in (`vpiVariables` vs `vpiNets` vs `vpiArrayNets`/`vpiArrayVars`, and
// as WHAT KIND) is read off golden per form and per view rather than assumed.
//
// EVERY CELL IS INSIDE A CHILD INSTANCE, for the same reason the other arms are.
//
//   d1  logic, plain                          d6  wire-typed struct (net)
//   d2  logic, DECLARED AND CONTINUOUSLY       d7  reg, driven by a cont_assign
//       ASSIGNED  <- the head's own form       d8  reg, NEVER driven
//   d3  logic, ranged (vector)                 d9  unpacked array of logic
//   d4  int                                    d10 IMPLICIT net (an undeclared
//   d5  struct-typed variable                      continuous-assign target)
package r122d;
  typedef struct packed {
    logic       s_v;
    logic [7:0] s_d;
  } d_t;
endpackage

module a3_kid122 #(
    parameter int M = 2
) (
    input  logic       clk,
    input  logic [7:0] d_i,
    output logic [7:0] o_o
);
  for (genvar i = 0; i < M; i++) begin : gd
    logic            d1;
    logic            d2;
    logic [7:0]      d3;
    int              d4;
    r122d::d_t       d5;
    wire r122d::d_t  d6;
    reg              d7;
    reg              d8;
    logic [7:0]      d9 [2];

    assign d2 = d_i[0];          // declared AND continuously assigned
    assign d6 = '{s_v: d2, s_d: d3};
    assign d7 = d_i[1];
    assign d10 = d_i[2];         // d10 is never declared: an IMPLICIT net
  end

  assign o_o = {7'b0, gd[0].d2 ^ gd[0].d6.s_v ^ gd[0].d7 ^ gd[0].d10};
endmodule

module a3_forms122 (
    input  logic       clk,
    input  logic [7:0] d_i,
    output logic [7:0] o_o
);
  a3_kid122 #(.M(2)) u_kid (.clk, .d_i, .o_o);
endmodule
