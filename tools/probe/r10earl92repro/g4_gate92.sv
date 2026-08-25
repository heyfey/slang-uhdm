// r10earl92 grid 4 — THE OPERAND GATE and the arm shapes the fold REFUSES.
// ExprEval::reduceExpr's `constantOperands` loop inspects ALL THREE operands,
// the UNTAKEN arm included, and abandons the WHOLE reduce on a shape it does
// not whitelist.  Every cell here keeps the head's context (plain ref_obj Lhs,
// constant-TRUE bare parameter) and a TAKEN arm that would fold on its own, so
// the only variable is the shape under test.
typedef struct packed { logic [31:0] m1; logic [31:0] m2; } g4st_t;

module g4leaf #(parameter bit EN = 1) (
  input  logic [7:0][31:0] k,
  input  logic [31:0]      sig,
  input  g4st_t            st,
  output logic [31:0]      o
);
  // ---- UNTAKEN-arm shapes (taken arm is always the head's xor) ----------
  logic [31:0] f_untk_const;   assign f_untk_const   = EN ? k[5] ^ k[1] : 32'h5;
  logic [31:0] f_untk_sig;     assign f_untk_sig     = EN ? k[5] ^ k[1] : sig;
  logic [31:0] f_untk_bitsel;  assign f_untk_bitsel  = EN ? k[5] ^ k[1] : k[2];
  logic [31:0] f_untk_partsel; assign f_untk_partsel = EN ? k[5] ^ k[1] : {16'b0, k[2][15:0]};
  logic [31:0] f_untk_barepsel;assign f_untk_barepsel= EN ? k[5][31:0] ^ k[1] : k[2][31:0];
  logic [31:0] f_untk_hier;    assign f_untk_hier    = EN ? k[5] ^ k[1] : st.m1;
  logic [31:0] f_untk_op;      assign f_untk_op      = EN ? k[5] ^ k[1] : k[2] ^ k[3];
  logic [31:0] f_untk_param;   assign f_untk_param   = EN ? k[5] ^ k[1] : EN;
  // ---- TAKEN-arm shapes that are NOT operations -------------------------
  logic [31:0] f_arm_hier;     assign f_arm_hier     = EN ? st.m1 : '0;
  logic [31:0] f_arm_hierop;   assign f_arm_hierop   = EN ? st.m1 ^ k[5] : '0;
  logic [31:0] f_arm_barepsel; assign f_arm_barepsel = EN ? {16'h0, k[5][15:0]} ^ k[1] : '0;
  logic [31:0] f_arm_sigop;    assign f_arm_sigop    = EN ? sig ^ k[5] : '0;
  // ---- CONDITION that is x/z, and an arm carrying x --------------------
  logic [31:0] f_arm_xz;       assign f_arm_xz       = EN ? 32'hx : k[5] ^ k[1];
  assign o = f_untk_const ^ f_untk_sig ^ f_untk_bitsel ^ f_untk_partsel ^
             f_untk_barepsel ^ f_untk_hier ^ f_untk_op ^ f_untk_param ^
             f_arm_hier ^ f_arm_hierop ^ f_arm_barepsel ^ f_arm_sigop ^ f_arm_xz;
endmodule

module g4top (input logic [7:0][31:0] k, input logic [31:0] sig, input g4st_t st,
              output logic [31:0] a);
  g4leaf #(.EN(1)) u1 (.k(k), .sig(sig), .st(st), .o(a));
endmodule
