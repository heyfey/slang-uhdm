// VERIFIER arm (r11v51) — ROAD B, the cut the pass did not make: b1 shows a
// CONCAT that reduces perfectly well is still kept.  The map reads that as
// "golden replaces the Rhs only when the whole Rhs IS the reference".  A rival
// reading is "golden never reduces an OPERATION in the elaborated package copy;
// a bare name is not reduced either — it is BOUND".  These two disagree on
// every operator that is not a concat, so cut them.
package pk;
  parameter logic [1:0] C0 = 2'b00;
  parameter logic [1:0] C3 = 2'b11;
  parameter logic [1:0] P1 = C0 + 2'b01;          // binary operation, reducible
  parameter logic [1:0] P2 = ~C0;                 // unary operation, reducible
  parameter logic [1:0] P3 = C0 ? C3 : C0;        // conditional, reducible
  parameter logic [1:0] P4 = {C0};                // 1-element concat, reducible
  parameter logic [1:0] P5 = (C3);                // parenthesised bare reference
  parameter logic [1:0] P6 = 2'(C3);              // width cast of a reference
  parameter int         P7 = C3 + 1;              // reducible, int holder
endpackage
package pk2;
  parameter logic [1:0] Q0 = pk::C3;              // bare ref ACROSS packages
  parameter logic [1:0] Q1 = pk::C3 + 2'b01;      // operation across packages
endpackage
module dut (output logic o);
  assign o = ^{pk::P1[0], pk::P2[0], pk::P3[0], pk::P4[0], pk::P5[0],
               pk::P6[0], pk::P7[0], pk2::Q0[0], pk2::Q1[0]};
endmodule
