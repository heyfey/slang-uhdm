// r10vearl117 ADVERSARIAL arm va3_scope117 — THE CARRIER-SCOPE FACES.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Gate (a) of § patCaGenIdxValueRender112 is `inGenScopeCa67` — a GEN-SCOPE
// CONTINUOUS ASSIGN.  This arm walks every neighbouring carrier, so that a
// gate that leaks would be caught by a golden that SPELLS:
//
//   t1  a pattern in a cont_assign inside a GENERATE CASE arm
//   t2  a pattern in an `always_ff` inside the generate body
//   t3  a pattern in an `always_latch` inside the generate body
//   t4  a pattern in an INSTANCE PORT CONNECTION inside the generate body
//   t5  a pattern in a cont_assign in a CHILD module instantiated inside a
//       generate, using the CHILD's OWN genvar
//   t6  a `for`-loop VARIABLE (not a genvar) as the index, in an always_comb
//   t7  a NESTED generate: the pattern in the INNER scope indexed by the
//       OUTER genvar
//   t8  a pattern in a MODULE-SCOPE cont_assign (generate depth 0)
//   t9  a pattern in the ELSE branch of a generate-if
//   t10 a pattern whose Lhs is a HIERARCHICAL target
package vs117;
  typedef struct packed {
    logic [3:0] t1;
    logic [3:0] t2;
  } pair_t;
endpackage

module va3_child117 #(
    parameter int CW = 2
) (
    input  logic [7:0]     cin,
    input  vs117::pair_t   cseed,
    output vs117::pair_t   cout [CW]
);
  logic [7:0] CBUS;
  assign CBUS = cin;
  for (genvar q = 0; q < CW; q++) begin : gen_child
    // t5 the CHILD's own genvar inside the CHILD's gen-scope pattern
    assign cout[q] = '{t1: {3'b0, CBUS[q]}, t2: cseed.t2 ^ 4'h1};
  end
endmodule

module va3_scope117 #(
    parameter int NW  = 4,
    parameter int SEL = 1
) (
    input  logic [7:0] din,
    output logic [3:0] dout
);
  logic [7:0]   SBUS;
  vs117::pair_t pa [NW];
  vs117::pair_t pb [NW];
  vs117::pair_t pc [NW];
  vs117::pair_t pd [NW];
  vs117::pair_t pe [NW];
  vs117::pair_t pf [NW][NW];
  vs117::pair_t pg;
  vs117::pair_t ph [NW];
  vs117::pair_t cw [2];

  assign SBUS = din;

  // t8 the MODULE-SCOPE pattern, generate depth 0 — must SPELL / must not move
  assign pg = '{t1: {3'b0, SBUS[SEL]}, t2: 4'h2};

  for (genvar j = 0; j < NW; j++) begin : gen_scope
    // t1 a GENERATE CASE arm holding the cont_assign
    case (SEL)
      1: begin : gen_case1
        assign pa[j] = '{t1: {3'b0, SBUS[j]}, t2: 4'h3};
      end
      default: begin : gen_casedef
        assign pa[j] = '{t1: 4'h0, t2: 4'h4};
      end
    endcase

    // t2 an always_ff carrier
    always_ff @(posedge din[7]) begin
      pb[j] <= '{t1: {3'b0, SBUS[j]}, t2: 4'h5};
    end

    // t3 an always_latch carrier
    always_latch begin
      if (din[6])
        pc[j] = '{t1: {3'b0, SBUS[j]}, t2: 4'h6};
    end

    // t6 a for-loop VARIABLE index inside an always_comb (not a genvar)
    always_comb begin
      pd[j] = '{t1: 4'h0, t2: 4'h0};
      for (int k = 0; k < NW; k++)
        pd[j] = '{t1: {3'b0, SBUS[k]}, t2: 4'h7};
    end

    // t9 the ELSE branch of a generate-if
    if (SEL == 99) begin : gen_ifyes
      assign pe[j] = '{t1: 4'h0, t2: 4'h8};
    end else begin : gen_ifno
      assign pe[j] = '{t1: {3'b0, SBUS[j]}, t2: 4'h9};
    end

    // t7 a NESTED generate whose pattern is indexed by the OUTER genvar
    for (genvar m = 0; m < NW; m++) begin : gen_inner
      assign pf[j][m] = '{t1: {3'b0, SBUS[j]}, t2: {3'b0, SBUS[m]}};
    end

    // t10 a GEN-LOCAL target written by a pattern, read back at module scope
    vs117::pair_t hsig;
    assign hsig = '{t1: {3'b0, SBUS[j]}, t2: 4'hA};
  end

  assign ph[0] = gen_scope[0].hsig;

  // t4 an INSTANCE PORT CONNECTION carrying a pattern, inside a generate
  for (genvar p = 0; p < 1; p++) begin : gen_inst
    va3_child117 #(.CW(2)) u_child (
        .cin(din),
        .cseed('{t1: {3'b0, SBUS[p]}, t2: 4'hB}),
        .cout(cw));
  end

  assign dout = pa[0].t1 ^ pb[0].t1 ^ pc[0].t1 ^ pd[0].t1 ^ pe[0].t1 ^
                pf[0][0].t1 ^ pg.t1 ^ ph[0].t1 ^ cw[0].t1;
endmodule
