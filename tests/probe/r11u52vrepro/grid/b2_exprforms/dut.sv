// b2 — BOUND EXPRESSION FORMS.  The law decides "numeric" by scanning rawText for
// non-digits, then hands anything else to emitSyntaxExpr and, in a copy, to a
// hand-rolled 3-kind cloner (constant / ref_obj / operation).  Every form below
// is legal SV in an element bound; the ones the cloner does not model must
// still come out right.
module dut #(parameter int N = 8, parameter int DEPTH = 4) (
  input logic clk,
  output logic o
);
  // plain symbolic — the law's own cell (control that it still works)
  typedef logic [N-1:0] t_plain [DEPTH];
  // WHITESPACE: rawText is "N - 1" -> non-numeric, same as t_plain
  typedef logic [N - 1:0] t_space [DEPTH];
  // PARENTHESISED
  typedef logic [(N-1):0] t_paren [DEPTH];
  // ARITHMETIC over two operands
  typedef logic [N*2-1:0] t_mul [DEPTH];
  // SYSTEM FUNCTION CALL inside the bound -> operation whose operand is a
  // sys_func_call; the cloner models only constant/ref_obj/operation
  typedef logic [$clog2(N)-1:0] t_clog [DEPTH];
  // SIZED LITERAL bound: rawText "4'd7" is NON-numeric by the digit scan
  typedef logic [4'd7:0] t_sized [DEPTH];
  // HEX literal, same class
  typedef logic ['h5:0] t_hex [DEPTH];
  // plain decimal literal -> numeric, must stay folded (control)
  typedef logic [7:0] t_lit [DEPTH];
  // a bound that is a BARE reference (no operation)
  typedef logic [N:0] t_bare [DEPTH];
  // BOTH bounds symbolic
  typedef logic [N-1:N-8] t_both [DEPTH];
  // TERNARY
  typedef logic [(N>4?N:4)-1:0] t_tern [DEPTH];

  t_plain a_plain; t_space a_space; t_paren a_paren; t_mul a_mul;
  t_clog a_clog;   t_sized a_sized; t_hex a_hex;     t_lit a_lit;
  t_bare a_bare;   t_both a_both;   t_tern a_tern;

  assign o = a_plain[0][0] ^ a_clog[0][0] ^ a_sized[0][0] ^ a_tern[0][0];
endmodule
