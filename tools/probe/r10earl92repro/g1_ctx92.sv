// r10earl92 grid 1 — CONTEXT x the head's arm shape.
// The condition is always a CONSTANT-TRUE bare parameter; the taken arm is
// always a NON-VALUE-ABLE xor of selects (exactly aes_key_expand.sv:109).
// The question every cell asks: does the ELABORATED view keep the ternary or
// install the selected arm?  Cell names are the LHS/context under test.
typedef struct packed { logic [31:0] m1; logic [31:0] m2; } st_t;

module g1sub (input logic [31:0] i0, output logic [31:0] o0);
  assign o0 = i0;
endmodule

module g1leaf #(parameter bit EN = 1) (
  input  logic [7:0][31:0] k,
  input  logic [31:0]      sig,
  output logic [31:0]      c_ca_plain,
  output logic [31:0]      c_operand,
  output logic [31:0]      c_nested,
  output logic [31:0]      c_notaken_sig,
  output logic [31:0]      c_cond_sig,
  output logic [31:0]      c_hc_out
);
  // --- the head shape: plain ref_obj LHS ------------------------------
  assign c_ca_plain = EN ? k[5] ^ k[1] ^ k[0] : '0;
  // --- select LHS shapes ---------------------------------------------
  logic [31:0] c_ca_bitsel_v;
  assign c_ca_bitsel_v[0] = EN ? k[5][0] ^ k[1][0] : 1'b0;
  logic [31:0] c_ca_partsel_v;
  assign c_ca_partsel_v[3:0] = EN ? k[5][3:0] ^ k[1][3:0] : 4'b0;
  st_t c_ca_member_s;
  assign c_ca_member_s.m1 = EN ? k[5] ^ k[1] : '0;
  logic [15:0] c_ca_cat_a, c_ca_cat_b;
  assign {c_ca_cat_a, c_ca_cat_b} = EN ? k[5] ^ k[1] : '0;
  // --- net-decl-assign ------------------------------------------------
  wire [31:0] c_netdecl = EN ? k[5] ^ k[1] : '0;
  // --- procedural assignment ------------------------------------------
  logic [31:0] c_proc;
  always_comb c_proc = EN ? k[5] ^ k[1] : '0;
  // --- the ternary as an OPERAND of a larger operation -----------------
  assign c_operand = (EN ? k[5] ^ k[1] : '0) ^ k[2];
  // --- nested ternary --------------------------------------------------
  assign c_nested = EN ? (EN ? k[5] ^ k[1] : k[2] ^ k[3]) : '0;
  // --- an UNTAKEN arm that is a BARE SIGNAL (the operand gate) ---------
  assign c_notaken_sig = EN ? k[5] ^ k[1] : sig;
  // --- a NON-CONSTANT condition ----------------------------------------
  assign c_cond_sig = sig[0] ? k[5] ^ k[1] : '0;
  // --- a port HIGH_CONN carrying the ternary ---------------------------
  g1sub u_hc (.i0(EN ? k[5] ^ k[1] : '0), .o0(c_hc_out));
endmodule

module g1top (input logic [7:0][31:0] k, input logic [31:0] sig,
              output logic [31:0] a1, a2, a3, a4, a5, a6);
  g1leaf #(.EN(1)) u1 (.k(k), .sig(sig), .c_ca_plain(a1), .c_operand(a2),
                       .c_nested(a3), .c_notaken_sig(a4), .c_cond_sig(a5),
                       .c_hc_out(a6));
endmodule
