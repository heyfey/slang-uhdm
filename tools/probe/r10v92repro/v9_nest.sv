// v92 adversarial arm 9 — nested ternaries, ternary-as-operand, and the
// interaction with the § elabCaTernaryFoldIntConst22 constant outcome.
module v9_nest #(parameter bit EN = 1, parameter bit EN2 = 0, parameter int N = 2) (
    input  logic [7:0] k,
    input  logic       sig,
    output logic [3:0] y_nn,      // ternary in both arms, both constant conds
    output logic [3:0] y_ncsig,   // inner condition NON-constant in taken arm
    output logic [3:0] y_untk_t,  // ternary in the UNTAKEN arm
    output logic [3:0] y_operand, // a ternary as an operand of a larger op
    output logic [3:0] y_chain3,  // three levels
    output logic [3:0] y_selarm   // arm folds to a CONSTANT (pass22 territory)
);
  assign y_nn      = EN  ? (EN2 ? (k[5] ^ k[1]) : (k[5] ^ k[2])) : 4'h0;
  assign y_ncsig   = EN  ? (sig ? (k[5] ^ k[3]) : (k[4] ^ k[1])) : 4'h0;
  assign y_untk_t  = EN  ? (k[4] ^ k[2]) : (EN2 ? 4'h1 : 4'h2);
  assign y_operand = (EN ? k[3:0] : 4'h0) ^ k[7:4];
  assign y_chain3  = EN  ? (EN2 ? 4'h1 : (N > 1 ? (k[3] ^ k[1]) : 4'h2)) : 4'h3;
  assign y_selarm  = EN  ? (N + 3) : 4'h0;
endmodule
