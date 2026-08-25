// r10earl91 g4 — THE HOME / INSTANCE / TYPEDEF-SPELLING GRID, and the
// NEGATIVE CONTROLS the law must not reach.
//   * the PARAMETER-INITIALIZER unpacked-array pattern (§ elabPatternFirstRow
//     ElemSize45's site, ExprEmit's `inParamInit && !paramInitDef` block) —
//     a DIFFERENT producer that this law must leave alone;
//   * the PACKED targets (vector / packed array / struct) — adjustOpSize's
//     other three branches, which DO write a size;
//   * the TYPEDEF'd unpacked array — Surelog fills `array_typespec::
//     Elem_typespec` for it (ElaborationStep.cpp:211), so golden DOES size
//     that one and we must keep doing so.
package s91;
  typedef struct packed { logic [11:0] q; } p_t;
  typedef struct packed { p_t prescale; logic [7:0] s; } c_t;
  typedef struct packed { c_t cfg0; logic ctrl; } rr_t;
  typedef logic [11:0] wd_t [2];        // typedef'd unpacked array, direct
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sm_t;
  typedef sm_t sma_t [2];               // typedef'd unpacked array of struct
  localparam logic [11:0] PP [2] = '{12'd1, 12'd2};   // PARAM-INIT control
endpackage

module leaf91 #(parameter int W = 12) (input logic [W-1:0] a_i, output logic [W-1:0] z_o);
  assign z_o = a_i;
endmodule

module g4_homes91 (input logic clk, output logic [63:0] o);
  import s91::*;
  rr_t reg2hw;
  localparam int NI = 3;

  // H1 typedef'd unpacked array, DIRECT spelling — golden SIZES operand 0
  wd_t  h1;  assign h1 = '{reg2hw.cfg0.prescale.q, 12'd4};
  // H2 typedef'd unpacked array OF STRUCT
  sma_t h2;  assign h2 = '{'{reg2hw.cfg0.prescale.q[3:0], 4'h2}, '{4'h3, 4'h4}};
  // H3 inline unpacked array — golden sizes NOTHING
  logic [11:0] h3 [2]; assign h3 = '{reg2hw.cfg0.prescale.q, 12'd5};
  // H4 module-scope PARAM-INIT control (a different producer)
  localparam logic [11:0] H4 [2] = '{12'd6, 12'd7};
  // H5 a PACKED-ARRAY target (adjustOpSize's logic branch: full/inner)
  logic [1:0][11:0] h5; assign h5 = '{reg2hw.cfg0.prescale.q, 12'd8};
  // H6 a PACKED STRUCT target (the flatten path)
  sm_t h6; assign h6 = '{reg2hw.cfg0.prescale.q[3:0], 4'h5};

  // H7 THREE INSTANCES of one module, each fed from an unpacked-array element
  logic [11:0] h7 [NI];
  assign h7 = '{reg2hw.cfg0.prescale.q, 12'd9, 12'd10};
  logic [11:0] z7 [NI];
  for (genvar gi = 0; gi < NI; gi++) begin : g_inst
    leaf91 u_l (.a_i(h7[gi]), .z_o(z7[gi]));
  end

  // H8 the SAME pattern inside a GENERATE scope
  logic [11:0] h8 [1];
  if (1) begin : g_blk
    logic [11:0] h8i [1];
    assign h8i = '{reg2hw.cfg0.prescale.q};
    assign h8 = '{h8i[0]};
  end

  // H9 an unpacked array assigned in an ALWAYS block (procedural)
  logic [11:0] h9 [1];
  always_comb h9 = '{reg2hw.cfg0.prescale.q};

  assign o = {4'd0, h1[0], h1[1], h3[0], h3[1], h5[0]} ^
             {40'd0, h2[0].a, h2[0].b, h2[1].a, h2[1].b, h6.a, h6.b} ^
             {28'd0, H4[0], H4[1], PP[0]} ^
             {28'd0, h7[0], z7[0], h8[0]} ^
             {52'd0, h9[0]};
endmodule
