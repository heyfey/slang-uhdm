// qc22.sv — PASS 22.  qb22 split the module-level constant-condition ternary
// in two and this file names the feature.  In the ELAB view golden
//   REDUCES  `P ? (a == 4'h3) : 1'b0`  and  `Q ? 1'b1 : (a == 4'h3)`
//            to a LOC-LESS constant with vpiIntConst (ct=7, INT value)
//   KEEPS    `P ? a : 4'd5` / `P ? a : 4'hb` / `P ? a : '0` as the operation
// Two features are confounded there: the LHS/result WIDTH (1 bit vs 4) and
// the shape of the NOT-taken branch (an operation vs a bare ref).  These rows
// cross them.
module qc22_child #(
    parameter bit P = 1'b0,
    parameter bit Q = 1'b1
) (
    input  logic       b,
    input  logic [3:0] a,
    output logic       u1,
    output logic [3:0] u2,
    output logic       u3,
    output logic [3:0] u4,
    output logic       u5,
    output logic [3:0] u6,
    output logic [3:0] u7,
    output logic [3:0] u8
);
  // 1-bit result, NOT-taken branch is a BARE REF
  assign u1 = P ? b : 1'b0;
  // 4-bit result, NOT-taken branch is an OPERATION
  assign u2 = P ? (a & 4'h3) : 4'd5;
  // 1-bit result, NOT-taken branch is a BIT-SELECT
  assign u3 = P ? a[0] : 1'b0;
  // 4-bit result, NOT-taken branch is a BARE REF, TAKEN branch 1 bit wide
  assign u4 = P ? a : 1'b1;
  // 1-bit result, both branches constant
  assign u5 = P ? 1'b1 : 1'b0;
  // 4-bit result, both branches constant
  assign u6 = P ? 4'h3 : 4'h5;
  // 4-bit result, NOT-taken branch is a FUNCTION-free operation on a const
  assign u7 = P ? (4'h3 & 4'h1) : 4'h9;
  // 4-bit result, TAKEN branch is an operation over constants
  assign u8 = P ? a : (4'h3 | 4'h8);
endmodule

module qc22 (
    input  logic       b,
    input  logic [3:0] a,
    output logic       u1,
    output logic [3:0] u2,
    output logic       u3,
    output logic [3:0] u4,
    output logic       u5,
    output logic [3:0] u6,
    output logic [3:0] u7,
    output logic [3:0] u8
);
  qc22_child u_c (.b(b), .a(a), .u1(u1), .u2(u2), .u3(u3), .u4(u4),
                  .u5(u5), .u6(u6), .u7(u7), .u8(u8));
endmodule
