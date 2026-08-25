// v92 adversarial arm 4 — ARM faces the reducer REWRITES or REFUSES.
// reduceExpr does not always hand the arm back untouched: a foldable
// multi-concat becomes a fresh constant, a foldable operation becomes an
// INT constant, a func_call it CAN evaluate becomes its result.  The patch
// installs the ORIGINAL arm expression in every one of those cases.
module v4_arm #(parameter bit EN = 1, parameter int N = 2) (
    input  logic [7:0] k,
    output logic [3:0] y_mcfold,   // {2{2'b01}} -> Surelog folds to a constant
    output logic [7:0] y_mcsig,    // {2{k[3:0]}} -> operands not constant
    output logic [3:0] y_addfold,  // N + 1 -> Surelog folds to INT
    output logic [3:0] y_catfold,  // {2'b01,2'b10} -> concat of constants
    output logic [3:0] y_catsig,   // {k[5],k[1],k[2],k[3]}
    output logic [3:0] y_castsig,  // 4'(k) - a cast of a signal
    output logic [3:0] y_str,      // a STRING arm
    output logic [3:0] y_xz,       // an X arm
    output logic [3:0] y_ones,     // '1
    output logic [3:0] y_zeros     // '0
);
  localparam logic [3:0] XV = 4'bx1x1;
  assign y_mcfold  = EN ? {2{2'b01}}      : 4'h0;
  assign y_mcsig   = EN ? {2{k[3:0]}}     : 8'h0;
  assign y_addfold = EN ? (N + 1)         : 4'h0;
  assign y_catfold = EN ? {2'b01, 2'b10}  : 4'h0;
  assign y_catsig  = EN ? {k[5],k[1],k[2],k[3]} : 4'h0;
  assign y_castsig = EN ? 4'(k)           : 4'h0;
  assign y_str     = EN ? "ab"            : 4'h0;
  assign y_xz      = EN ? XV              : 4'h0;
  assign y_ones    = EN ? '1              : 4'h0;
  assign y_zeros   = EN ? '0              : (k[3] ^ k[1]);
endmodule
