// r10earl92 grid 3 — ARM SHAPES, on the head's context (plain ref_obj Lhs,
// constant-TRUE bare-parameter condition).  Every cell asks WHICH OBJECT the
// elaborated cont_assign ends up holding: the whole ternary, the arm verbatim,
// or a folded constant (the last two already owned by other laws).
typedef struct packed { logic [31:0] m1; logic [31:0] m2; } g3st_t;

module g3leaf #(parameter bit EN = 1, parameter int PW = 7) (
  input  logic [7:0][31:0] k,
  input  logic [31:0]      sig,
  input  g3st_t            st,
  output logic [31:0]      o
);
  function automatic logic [31:0] fsig(input logic [31:0] x);
    return x ^ 32'h1;
  endfunction
  // e_xor_sel   — the head: an xor of bit-selects (NOT value-able)
  logic [31:0] e_xor_sel;   assign e_xor_sel   = EN ? k[5] ^ k[1] ^ k[0] : '0;
  // e_literal   — a sized literal arm (value-able -> INT constant)
  logic [31:0] e_literal;   assign e_literal   = EN ? 32'hdead : '0;
  // e_unsized   — an unbased-unsized arm
  logic [31:0] e_unsized;   assign e_unsized   = EN ? '1 : '0;
  // e_foldable  — an arm that reduces FURTHER to a constant
  logic [31:0] e_foldable;  assign e_foldable  = EN ? (32'h3 | 32'h1) : '0;
  // e_param     — an arm that is a bare PARAMETER read
  logic [31:0] e_param;     assign e_param     = EN ? PW : 0;
  // e_bitsel    — a single bit-select arm (not value-able, not an operation)
  logic [31:0] e_bitsel;    assign e_bitsel    = EN ? k[5] : '0;
  // e_baresig   — a BARE SIGNAL arm (the operand gate says: no fold at all)
  logic [31:0] e_baresig;   assign e_baresig   = EN ? sig : '0;
  // e_partsel   — a PART-SELECT arm (part_select is NOT in the operand gate)
  logic [31:0] e_partsel;   assign e_partsel   = EN ? {16'b0, k[5][15:0]} : '0;
  // e_concat    — a CONCATENATION arm
  logic [31:0] e_concat;    assign e_concat    = EN ? {k[5][15:0], k[1][15:0]} : '0;
  // e_hier      — a struct MEMBER READ arm (hier_path)
  logic [31:0] e_hier;      assign e_hier      = EN ? st.m1 : '0;
  // e_call      — a USER FUNCTION CALL arm over a signal
  logic [31:0] e_call;      assign e_call      = EN ? fsig(k[5]) : '0;
  // e_syscall   — a $-call arm ExprEval implements
  logic [31:0] e_syscall;   assign e_syscall   = EN ? $clog2(PW) : '0;
  // e_syscall_x — a $-call arm ExprEval does NOT implement
  logic [31:0] e_syscall_x; assign e_syscall_x = EN ? $countones(k[5]) : '0;
  // e_unary     — a UNARY arm (reduce has a case; the operand is not value-able)
  logic [31:0] e_unary;     assign e_unary     = EN ? ~k[5] : '0;
  // e_redxor    — a REDUCTION-xor arm
  logic [31:0] e_redxor;    assign e_redxor    = EN ? {31'b0, ^k[5]} : '0;
  // e_add       — an ARITHMETIC arm over selects (reduce HAS a vpiAddOp case)
  logic [31:0] e_add;       assign e_add       = EN ? k[5] + k[1] : '0;
  // e_shift     — a SHIFT arm over selects (reduce HAS a shift case)
  logic [31:0] e_shift;     assign e_shift     = EN ? k[5] << 2 : '0;
  // e_cast      — a CAST arm over a select
  logic [31:0] e_cast;      assign e_cast      = EN ? 32'(k[5][7:0]) : '0;
  // e_nestedop  — a THREE-deep operand tree, exactly the head's shape
  logic [31:0] e_nestedop;  assign e_nestedop  = EN ? (k[5] ^ k[1]) ^ (k[2] ^ k[3]) : '0;
  assign o = e_xor_sel ^ e_literal ^ e_unsized ^ e_foldable ^ e_param ^
             e_bitsel ^ e_baresig ^ e_partsel ^ e_concat ^ e_hier ^ e_call ^
             e_syscall ^ e_syscall_x ^ e_unary ^ e_redxor ^ e_add ^ e_shift ^
             e_cast ^ e_nestedop;
endmodule

module g3top (input logic [7:0][31:0] k, input logic [31:0] sig, input g3st_t st,
              output logic [31:0] a);
  g3leaf #(.EN(1)) u1 (.k(k), .sig(sig), .st(st), .o(a));
endmodule
