// v92 adversarial arm 7 — the OPERAND GATE, and the kindOf92 mapping of every
// slang ExpressionKind the patch calls an "operation".
// constantOperands walks ALL THREE operands one level deep.  Every cell here
// puts an exotic operand in the UNTAKEN arm, where it can only ever REFUSE
// the fold, and in the TAKEN arm, where it decides what gets installed.
package vp7;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
endpackage

module v7_gate #(parameter bit EN = 1, parameter int N = 2) (
    input  logic [7:0]  k,
    input  logic [15:0] wide,
    input  vp7::e_t     ein,
    input  logic        sig,
    output logic [3:0]  y_untk_stream,
    output logic [3:0]  y_untk_inside,
    output logic [3:0]  y_untk_ap,
    output logic [3:0]  y_arm_stream,
    output logic [3:0]  y_arm_inside,
    output logic [3:0]  y_arm_ap,
    output logic [3:0]  y_arm_enum,
    output logic [3:0]  y_untk_idxps,
    output logic [3:0]  y_arm_repl,
    output logic [3:0]  y_arm_shift
);
  logic [3:0] apv [0:1];
  assign y_untk_stream = EN ? (k[5] ^ k[1]) : {<<{k[3:0]}};
  assign y_untk_inside = EN ? (k[5] ^ k[2]) : {3'b0, sig inside {1'b0,1'b1}};
  assign y_untk_ap     = EN ? (k[5] ^ k[3]) : '{default: 1'b0};
  assign y_arm_stream  = EN ? {<<{k[3:0]}}  : 4'h0;
  assign y_arm_inside  = EN ? {3'b0, sig inside {1'b0,1'b1}} : 4'h0;
  assign y_arm_ap      = EN ? '{default: 1'b1} : 4'h0;
  assign y_arm_enum    = EN ? {2'b0, ein}   : 4'h0;
  assign y_untk_idxps  = EN ? (k[4] ^ k[1]) : wide[4 +: 4];
  assign y_arm_repl    = EN ? {4{sig}}      : 4'h0;
  assign y_arm_shift   = EN ? (k[7:4] >> N) : 4'h0;
endmodule
