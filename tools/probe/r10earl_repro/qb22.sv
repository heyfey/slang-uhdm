// qb22.sv — PASS 22, the layer behind § genCaEnumBindsSelectOnly22:
//   work@top_earlgrey > u_rv_core_ibex > u_core > ex_block_i > alu_i
//     > cont_assign ibex_alu.sv:244:10 > vpiRhs
//         golden constant :0:0 {ct=7 sz=1 dec=0}    (vpiIntConst)
//         ours   constant :0:0 {ct=9 sz=1 dec=0}    (vpiUIntConst)
// ibex_alu.sv:244 is `assign bfp_op = RV32B ? (operator_i == ALU_BFP) : 1'b0;`
// with `parameter bit RV32B = 1'b0`, i.e. a ternary whose CONDITION is a
// constant FALSE, so Surelog's reduce collapses the whole RHS to the taken
// branch.  qa22's R7/R8 showed the same ct=7 on a whole-RHS reduce in a gen
// scope, so the question this file answers is WHICH spellings of a
// reduced-to-constant cont_assign RHS carry vpiIntConst.
// Rows: taken-branch literal spelling (bin / dec / hex / '0), condition
// true vs false, whole-RHS constant with no ternary, and the same rows in a
// gen scope and in a child instance.
module qb22_child #(
    parameter bit P = 1'b0,
    parameter bit Q = 1'b1
) (
    input  logic [3:0] a,
    output logic       t1,
    output logic       t2,
    output logic [3:0] t3,
    output logic [3:0] t4,
    output logic [3:0] t5,
    output logic [3:0] t6,
    output logic [3:0] t7,
    output logic [3:0] g1,
    output logic [3:0] g2
);
  assign t1 = P ? (a == 4'h3) : 1'b0;   // T1  ibex_alu.sv:244 verbatim shape
  assign t2 = Q ? 1'b1 : (a == 4'h3);   // T2  condition TRUE, literal taken
  assign t3 = P ? a : 4'd5;             // T3  taken branch a DECIMAL literal
  assign t4 = P ? a : 4'hb;             // T4  taken branch a HEX literal
  assign t5 = P ? a : '0;               // T5  taken branch an unsized '0
  assign t6 = 4'h7;                     // T6  no ternary, bare literal RHS
  assign t7 = 4'h7 | 4'h8;              // T7  no ternary, constant operation

  if (1) begin : gen_if
    assign g1 = P ? a : 4'hb;           // G1  T4 inside a gen scope
    assign g2 = 4'h7 | 4'h8;            // G2  T7 inside a gen scope
  end
endmodule

module qb22 (
    input  logic [3:0] a,
    output logic       t1,
    output logic       t2,
    output logic [3:0] t3,
    output logic [3:0] t4,
    output logic [3:0] t5,
    output logic [3:0] t6,
    output logic [3:0] t7,
    output logic [3:0] g1,
    output logic [3:0] g2
);
  qb22_child u_c (.a(a), .t1(t1), .t2(t2), .t3(t3), .t4(t4), .t5(t5),
                  .t6(t6), .t7(t7), .g1(g1), .g2(g2));
endmodule
