// qm27 — THE FRONTIER after § patternElabDeclOrderMembers27, two operands
// later in the SAME pattern:
//   [5] rel=97[8]  operation tlul_adapter_host.sv:95:16 {op=75}
//                  rel=97 VECTOR SIZE 3 vs 1
//   [6] rel=97[0]  A constant :95:26 {ct=9 sz=7 dec=0}
//                  B constant :95:26 {ct=3 sz=1 dec='0}
// i.e. `a_user: '{default:'0}` — a NESTED struct pattern with a DEFAULT setter.
// tlul_pkg::tl_a_user_t is {logic [6:0] rsvd1; logic parity_en; logic [7:0]
// parity;}, and LHS(golden) emits THREE operands (one per member, `'0` folded
// UINT at each member's own width, decompile "0") where RHS(ours) emits ONE
// (the written `'0`, BIN at size 1).
// Rows: the corpus shape, `'1`, an explicitly sized default, a default beside a
// named member, and a NON-nested top-level default pattern, in a child instance
// so the DEF and ELAB views are both measured.
package qm27_pkg;
  typedef struct packed {
    logic [6:0] u_rsvd;
    logic       u_en;
    logic [7:0] u_par;
  } usr_t;

  typedef struct packed {
    logic [1:0] m_a;
    usr_t       m_u;
    logic [3:0] m_b;
  } outer_t;
endpackage

module qm27_child (
  input  logic [1:0]     a_i,
  input  logic [3:0]     b_i,
  output qm27_pkg::outer_t o0_o,
  output qm27_pkg::outer_t o1_o,
  output qm27_pkg::outer_t o2_o,
  output qm27_pkg::outer_t o3_o,
  output qm27_pkg::usr_t   u_o
);
  // A: THE CORPUS SHAPE — a nested `'{default:'0}` member value.
  assign o0_o = '{
      m_a: a_i,
      m_u: '{default: '0},
      m_b: b_i
  };
  // B: the same with `'1`.
  assign o1_o = '{
      m_a: a_i,
      m_u: '{default: '1},
      m_b: b_i
  };
  // C: an explicitly SIZED default value.
  assign o2_o = '{
      m_a: a_i,
      m_u: '{default: 1'b0},
      m_b: b_i
  };
  // D: a default BESIDE a named member of the same nested struct.
  assign o3_o = '{
      m_a: a_i,
      m_u: '{u_en: 1'b1, default: '0},
      m_b: b_i
  };
  // E: a NON-nested top-level default pattern (the control).
  assign u_o = '{default: '0};
endmodule

module qm27 (
    input  logic [1:0]     a_i,
    input  logic [3:0]     b_i,
    output qm27_pkg::outer_t o0_o,
    output qm27_pkg::outer_t o1_o,
    output qm27_pkg::outer_t o2_o,
    output qm27_pkg::outer_t o3_o,
    output qm27_pkg::usr_t   u_o
);
  qm27_child u_c (
      .a_i(a_i), .b_i(b_i),
      .o0_o(o0_o), .o1_o(o1_o), .o2_o(o2_o), .o3_o(o3_o), .u_o(u_o)
  );
endmodule
