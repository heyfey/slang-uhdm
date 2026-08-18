// r10earl66 GRID ARM 1 — WHERE does an ENUM-CONSTANT READ fold in the
// ELABORATED port High_conn, and with WHAT encoding?
// Positions: bit-select INDEX / ips BASE / ips WIDTH / part-select bounds /
// bare actual / operation operand / concat operand / ternary arm, plus the
// cont_assign and procedural homes as the negative controls.
// Homes: module body / gen-for / gen-if.  Enum ORIGIN: package / module-local.
// MEASUREMENT ONLY.
package pe66;
  typedef enum logic [2:0] {          // sized HEX written encodings
    EH0 = 3'h0,
    EH1 = 3'h1,
    EH4 = 3'h4
  } hex_e;
  typedef enum logic [7:0] {          // sized DECIMAL written encodings
    ED5 = 8'd5,
    ED6 = 8'd6
  } dec_e;
  typedef enum logic [3:0] {          // sized BINARY written encodings
    EB1 = 4'b0001,
    EB2 = 4'b0010
  } bin_e;
  typedef enum {                      // UNTYPED base, decimal-written
    EU0 = 0,
    EU1 = 1
  } unt_e;
  typedef enum logic [2:0] {          // AUTO-VALUED (no written literal)
    EA0,
    EA1,
    EA2
  } auto_e;
  typedef enum int {                  // int base, auto-valued
    EI0,
    EI1
  } int_e;
  typedef enum bit [7:0] {            // bit base, mixed written/auto
    EM3 = 8'h3,
    EM4                                // auto-increments to 4
  } mix_e;
endpackage

module leaf66 (
  input  logic [31:0] a_i,
  input  logic        b_i,
  output logic        o_o
);
  assign o_o = ^a_i ^ b_i;
endmodule

module g1_enum66 import pe66::*; (
  input  logic [63:0] d_i,
  input  logic        clk_i,
  output logic [31:0] o_o
);
  // module-LOCAL enum, same shapes
  typedef enum logic [2:0] { LH0 = 3'h0, LH2 = 3'h2 } lhex_e;
  typedef enum { LU0 = 0, LU1 = 1 }                   lunt_e;

  logic [63:0] arr;
  assign arr = d_i;

  // ---- ELAB High_conn: BIT-SELECT INDEX, every encoding
  leaf66 u_i_h0  (.a_i(32'(d_i[EH0])),  .b_i(1'b0), .o_o(o_o[0]));
  leaf66 u_i_h4  (.a_i(32'(d_i[EH4])),  .b_i(1'b0), .o_o(o_o[1]));
  leaf66 u_i_d5  (.a_i(32'(d_i[ED5])),  .b_i(1'b0), .o_o(o_o[2]));
  leaf66 u_i_b2  (.a_i(32'(d_i[EB2])),  .b_i(1'b0), .o_o(o_o[3]));
  leaf66 u_i_u1  (.a_i(32'(d_i[EU1])),  .b_i(1'b0), .o_o(o_o[4]));
  leaf66 u_i_a2  (.a_i(32'(d_i[EA2])),  .b_i(1'b0), .o_o(o_o[5]));
  leaf66 u_i_i1  (.a_i(32'(d_i[EI1])),  .b_i(1'b0), .o_o(o_o[6]));
  leaf66 u_i_m4  (.a_i(32'(d_i[EM4])),  .b_i(1'b0), .o_o(o_o[7]));
  leaf66 u_i_lh2 (.a_i(32'(d_i[LH2])),  .b_i(1'b0), .o_o(o_o[8]));
  leaf66 u_i_lu1 (.a_i(32'(d_i[LU1])),  .b_i(1'b0), .o_o(o_o[9]));
  // a BARE bit-select actual (no cast) — the Earlgrey head's own spelling
  leaf66 u_i_bare (.a_i(32'(d_i)), .b_i(d_i[EH1]), .o_o(o_o[10]));

  // ---- ELAB High_conn: ips BASE / ips WIDTH / part-select bounds
  leaf66 u_ipsb  (.a_i(d_i[EH1 +: 32]), .b_i(1'b0), .o_o(o_o[11]));
  leaf66 u_ipsw  (.a_i(32'(d_i[0 +: ED5])), .b_i(1'b0), .o_o(o_o[12]));
  leaf66 u_ps    (.a_i(32'(d_i[ED6:ED5])),  .b_i(1'b0), .o_o(o_o[13]));

  // ---- ELAB High_conn: BARE actual / operation operand / concat / ternary
  leaf66 u_barea (.a_i(32'(EH4)),           .b_i(1'b0), .o_o(o_o[14]));
  leaf66 u_op    (.a_i(32'(EH4 + 1)),       .b_i(1'b0), .o_o(o_o[15]));
  leaf66 u_cat   (.a_i({29'b0, EH4}),       .b_i(1'b0), .o_o(o_o[16]));
  leaf66 u_tern  (.a_i(d_i[0] ? 32'(EH4) : 32'(EH1)), .b_i(1'b0), .o_o(o_o[17]));
  leaf66 u_cmp   (.a_i(32'(d_i)), .b_i(d_i[2:0] == EH4), .o_o(o_o[18]));

  // ---- cont_assign homes (the NEGATIVE controls)
  logic ca_idx, ca_cmp;
  logic [31:0] ca_bare;
  assign ca_idx  = d_i[EH4];
  assign ca_cmp  = (d_i[2:0] == EH4);
  assign ca_bare = 32'(EH4);

  // ---- procedural home
  logic pr_idx;
  always_comb pr_idx = d_i[EH4];

  // ---- gen-for home
  logic [1:0] gf;
  for (genvar i = 0; i < 2; i++) begin : gen_for
    leaf66 u_gf (.a_i(32'(d_i[EH4])), .b_i(1'b0), .o_o(gf[i]));
  end
  // ---- gen-if home
  logic gi;
  if (1) begin : gen_if
    leaf66 u_gi (.a_i(32'(d_i[EH1])), .b_i(1'b0), .o_o(gi));
  end
  assign o_o[31:19] = {ca_idx, ca_cmp, pr_idx, gf, gi, ca_bare[7:0]};
endmodule
