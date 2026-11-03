// § addOperandConstMint475
// leaves that keep UINT (hex, binary, enum member, cast, plain decimal) beside 'd leaves
package a;
  typedef enum logic [3:0] {E0, E1, E2} e_t;
  parameter logic [7:0] H = 8'h10;
  parameter logic [7:0] S1 = H + 1;
  parameter logic [7:0] S2 = 4'b0011 + 1;
  parameter logic [7:0] S3 = E2 + 1;
  parameter logic [7:0] S4 = 8'(3) + 1;
  parameter logic [7:0] S5 = 1 + 2;
  parameter logic [7:0] S6 = 1 + 8'd2;
  parameter logic [7:0] S7 = (H + 8'sd2) + 1;
endpackage
module top(output logic [7:0] y);
  import a::*;
  assign y = S1 ^ S2 ^ S3 ^ S4 ^ S5 ^ S6 ^ S7;
endmodule
