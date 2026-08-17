// r10earl59 VERIFIER arm W2 — Rhs KIND divergence and LHS TYPE breadth.
// writeCont_assign tests SURELOG'S netlist Rhs kind BEFORE reduceExpr; the
// patch tests OUR EMITTED Rhs kind.  Any shape where the two disagree is a
// candidate pristine-right -> patched-wrong.  One row per axis.
module w2sub #(parameter int W = 4, parameter logic [3:0] P = 4'h3) (
  input               clk,
  input        [3:0]  din,
  inout        [3:0]  io_p,          // INOUT port net LHS
  output       [3:0]  o_ansi,
  output logic [3:0]  o_var
);
  typedef struct packed { logic [3:0] f; logic [3:0] g; } st_t;
  typedef enum logic [1:0] { E_A, E_B } en_t;
  wire  [3:0] mn_src;
  logic       me;
  st_t        m_st;                  // module STRUCT var LHS
  st_t        m_st2;                 // module STRUCT var LHS, pattern Rhs
  en_t        m_en;                  // module ENUM var LHS
  int         m_int;                 // module 2-state INT var LHS (if-gen)
  real        m_real;                // module REAL var LHS
  wire  [3:0] mn_par, mn_lp, mn_sys, mn_str, mn_ins, mn_cat, mn_nda = din;
  wire  [3:0] mn_selop;
  localparam int LP = 2;
  assign mn_src = din;
  assign me     = din[0];
  assign mn_imp = din;   // creates the module-level IMPLICIT net mn_imp

  if (1) begin : g_a
    if (1) begin : g_b
      wire [3:0] lb;
      assign lb = mn_src;
      assign mn_par    = P + 4'h1;           // parameter operand operation
      assign mn_lp     = LP + 1;             // localparam operand operation
      assign mn_sys    = $signed(lb) + 4'h1; // operation with a sys call inside
      assign mn_str    = {<<{lb}};           // streaming
      assign mn_ins    = {3'b0, lb inside {4'd1, 4'd2}};
      assign mn_cat    = {lb[1:0], mn_src[1:0]};
      assign mn_selop  = lb[2:1] | mn_src[2:1];
      assign mn_nda    = lb | mn_src;        // ALSO net-decl-assign driven
      assign io_p      = lb | mn_src;        // INOUT port net
      assign o_ansi    = lb | mn_src;
      assign o_var     = lb | mn_src;
      assign m_st      = {lb, lb} | 8'h0;    // struct var, operation
      assign m_st2     = '{f: lb, g: lb};    // ASSIGNMENT PATTERN Rhs (operation)
      assign m_en      = en_t'(lb[1:0] | 2'b0);
      assign m_int     = lb + 1;             // int var, IF-gen
      assign m_real    = 1.5 + 2.5;          // real var, operation
      assign mn_imp    = lb | mn_src;        // MODULE-level IMPLICIT net, d2
    end
  end
endmodule

module a1;
  wire clk; wire [3:0] din; wire [3:0] a1, a2; wire [3:0] b1, b2;
  wire [3:0] ioa, iob;
  w2sub u_sub  (.clk(clk), .din(din), .io_p(ioa), .o_ansi(a1), .o_var(a2));
  w2sub #(.W(8), .P(4'h7)) u_sub2 (.clk(clk), .din(din), .io_p(iob),
                                   .o_ansi(b1), .o_var(b2));
endmodule
