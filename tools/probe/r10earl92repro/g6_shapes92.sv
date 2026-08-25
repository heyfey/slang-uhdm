// r10earl92 grid 6 — the REMAINING operand/arm shapes: a TRUE part_select
// (the one operand kind ExprEval's `constantOperands` loop does NOT whitelist),
// patterns, strings, reals, an ENUM read, an interface-free hierarchical read,
// and a ternary in a BIND-instantiated module.
package g6pkg;
  typedef enum logic [1:0] { E0 = 0, E1 = 1 } g6e_t;
endpackage

module g6leaf #(parameter bit EN = 1) (
  input  logic [31:0]      vec,
  input  logic [7:0][31:0] k,
  input  g6pkg::g6e_t      ev,
  output logic [31:0]      o
);
  // p_arm_partsel  — a BARE part-select of a plain vector (UHDM part_select)
  logic [31:0] p_arm_partsel;  assign p_arm_partsel  = EN ? {16'b0, vec[15:0]} : '0;
  logic [15:0] p_arm_bareps;   assign p_arm_bareps   = EN ? vec[15:0] : '0;
  // p_untk_partsel — the UNTAKEN arm is a bare part-select
  logic [15:0] p_untk_partsel; assign p_untk_partsel = EN ? vec[31:16] : vec[15:0];
  // p_cond_partsel — the CONDITION is a part-select
  logic [31:0] p_cond_partsel; assign p_cond_partsel = |vec[1:0] ? k[5] ^ k[1] : k[2] ^ k[3];
  // p_arm_enum     — an ENUM-typed read arm
  logic [1:0]  p_arm_enum;     assign p_arm_enum     = EN ? ev : g6pkg::E0;
  // p_arm_str      — a STRING arm
  // p_arm_real     — a REAL arm
  real         p_arm_real;     assign p_arm_real     = EN ? 1.5 : 2.5;
  // p_arm_pat      — an ASSIGNMENT-PATTERN arm
  logic [1:0][15:0] p_arm_pat; assign p_arm_pat      = EN ? '{vec[15:0], vec[31:16]} : '0;
  // p_arm_idxps    — an INDEXED part-select arm
  logic [7:0]  p_arm_idxps;    assign p_arm_idxps    = EN ? vec[7 -: 8] : '0;
  // p_untk_idxps   — the UNTAKEN arm is an indexed part-select
  logic [7:0]  p_untk_idxps;   assign p_untk_idxps   = EN ? vec[15:8] : vec[7 -: 8];
  assign o = {30'b0, p_arm_enum} ^ p_arm_partsel ^ {16'b0, p_arm_bareps} ^
             {16'b0, p_untk_partsel} ^ p_cond_partsel ^ {16'b0, p_arm_pat[0]} ^
             {24'b0, p_arm_idxps} ^ {24'b0, p_untk_idxps};
endmodule

module g6top (input logic [31:0] vec, input logic [7:0][31:0] k,
              input g6pkg::g6e_t ev, output logic [31:0] a);
  import g6pkg::*;
  g6leaf #(.EN(1)) u1 (.vec(vec), .k(k), .ev(ev), .o(a));
endmodule
