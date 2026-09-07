// r10vearl113 (VERIFIER) arm v2 -- THE PATTERN-SHAPE AXIS at generate depth 1,
// each cell beside its MODULE-SCOPE twin.  MEASUREMENT ONLY.
//   b1  a KEYED pattern whose keys are written in REVERSE member order
//   b2  a KEYED pattern with a trailing `default:`
//   b3  a NESTED pattern as the FIRST operand (the `!nestedPat` fence)
//   b4  an UNSIZED `'0` first operand (the constant exception's other half)
//   b5  a SIZED narrow literal into a WIDE first member (the discriminator)
//   b6  a TERNARY first operand
//   b7  a CONCATENATION first operand into a wide member
//   b8  a MULTI assignment pattern (replication) on a packed array target
package pv2113;
  typedef enum logic [2:0] { WA = 3'h0, WB = 3'h4 } we_e;
  // an 8-bit FIRST member: the width the stamp would write, so a narrower
  // literal in that slot separates "the literal's own width" from "the member
  // width" by number and not by argument.
  typedef struct packed {
    logic [7:0] w0;
    we_e        o;
    logic [7:0] d;
  } ws_t;
  typedef struct packed {
    logic       n0;
    we_e        n1;
  } inner_t;
  typedef struct packed {
    inner_t     inr;
    we_e        o;
    logic [7:0] d;
  } outer_t;
endpackage

module v2_pat113 #(parameter int M = 2) (
  input  logic       clk,
  input  pv2113::ws_t tl_i [M],
  input  logic [7:0] d_i,
  input  logic       s_i,
  output logic       y_o
);
  // ---- MODULE-SCOPE TWINS (golden SIZES operand 0 in every one) ----
  pv2113::ws_t    m_rev, m_def, m_uns, m_lit, m_ter, m_cat;
  pv2113::outer_t m_nst;
  assign m_rev = '{ d: d_i, o: tl_i[0].o, w0: tl_i[0].w0 };
  assign m_def = '{ w0: tl_i[0].w0, o: pv2113::WB, default: '0 };
  assign m_nst = '{ inr: '{ n0: tl_i[0].w0[0], n1: tl_i[0].o }, o: tl_i[0].o, d: d_i };
  assign m_uns = '{ w0: '0, o: tl_i[0].o, d: d_i };
  assign m_lit = '{ w0: 4'h3, o: tl_i[0].o, d: d_i };
  assign m_ter = '{ w0: s_i ? tl_i[0].w0 : d_i, o: tl_i[0].o, d: d_i };
  assign m_cat = '{ w0: {d_i[3:0], tl_i[0].w0[3:0]}, o: tl_i[0].o, d: d_i };

  // ---- GENERATE DEPTH 1, gen-local targets ----
  for (genvar i = 0; i < M; i++) begin : gen_b
    pv2113::ws_t    b1_rev, b2_def, b4_uns, b5_lit, b6_ter, b7_cat;
    pv2113::outer_t b3_nst;
    assign b1_rev = '{ d: d_i, o: tl_i[i].o, w0: tl_i[i].w0 };
    assign b2_def = '{ w0: tl_i[i].w0, o: pv2113::WB, default: '0 };
    assign b3_nst = '{ inr: '{ n0: tl_i[i].w0[0], n1: tl_i[i].o }, o: tl_i[i].o, d: d_i };
    assign b4_uns = '{ w0: '0, o: tl_i[i].o, d: d_i };
    assign b5_lit = '{ w0: 4'h3, o: tl_i[i].o, d: d_i };
    assign b6_ter = '{ w0: s_i ? tl_i[i].w0 : d_i, o: tl_i[i].o, d: d_i };
    assign b7_cat = '{ w0: {d_i[3:0], tl_i[i].w0[3:0]}, o: tl_i[i].o, d: d_i };
  end

  // b8  A MULTI ASSIGNMENT PATTERN (replication) -- module twin and gen-local
  logic [3:0][7:0] m_rep;
  assign m_rep = '{ 4{ d_i } };
  for (genvar i = 0; i < M; i++) begin : gen_b8
    logic [3:0][7:0] b8_rep;
    assign b8_rep = '{ 4{ d_i } };
  end

  assign y_o = m_rev.w0[0] ^ m_def.w0[0] ^ m_nst.inr.n0 ^ m_uns.w0[0] ^
               m_lit.w0[0] ^ m_ter.w0[0] ^ m_cat.w0[0] ^ m_rep[0][0];
endmodule
