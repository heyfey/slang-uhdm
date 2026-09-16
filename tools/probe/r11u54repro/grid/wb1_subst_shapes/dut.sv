// r11u54 arm — LAW B re-cut: in the elaborated PACKAGE copy the producer
// substitutes the reduced object for the WHOLE Rhs unless the Rhs tree
// CONTAINS a concatenation or a replication ANYWHERE (the refusal recurses
// into operands).  vb1 cut nine operand kinds and vb2 six concat shapes; this
// arm crosses the two — a concat buried under a cast / a conditional branch /
// a part-select, and the same shapes across packages and as a localparam.
package pk;
  parameter logic [3:0]  C0 = 4'b0001;
  parameter logic [3:0]  C3 = 4'b0011;
  // --- no concat anywhere: every one of these must SUBSTITUTE ---
  parameter logic [3:0]  S1 = C0 << 1;                 // shift
  parameter logic [3:0]  S2 = (C0 < C3) ? C0 : C3;     // conditional + comparison
  parameter logic [3:0]  S3 = C0 & C3;                 // bitwise
  parameter logic [3:0]  S7 = C0[1:0] + C3[1:0];       // part-selects
  parameter logic [3:0]  S10 = 4'(C0 + C3);            // cast over a binary op
  parameter logic [3:0]  S11 = -C0;                    // unary minus
  // --- a concat/replication SOMEWHERE: every one of these must be KEPT ---
  parameter logic [3:0]  S4 = {C0[1:0], C3[1:0]};      // concat over part-selects
  parameter logic [3:0]  S5 = C0 ? {C0} : C3;          // concat in a cond BRANCH
  parameter logic [3:0]  S6 = 4'({2{C0[1:0]}});        // replication under a CAST
  parameter logic [7:0]  S9 = {C0, 4'h5};              // concat, one ref one literal
  localparam logic [3:0] S8 = {2{C0[1:0]}};            // LOCALPARAM replication
  localparam logic [3:0] S12 = {C0[1:0], C3[1:0]} & 4'hF;  // concat under an AND
endpackage
package pk2;
  parameter logic [3:0] T0 = {pk::C0[1:0], pk::C3[1:0]};  // cross-package concat
  parameter logic [3:0] T1 = pk::C0 + pk::C3;             // cross-package, no concat
  parameter logic [3:0] T2 = 4'({2{pk::C0[1:0]}});        // cross-package replication
endpackage
// MODULE-SCOPE control: golden folds all of these whole; ours already agrees.
module dut (output logic o);
  localparam logic [3:0] M1 = {pk::C0[1:0], pk::C3[1:0]};
  localparam logic [3:0] M2 = {2{pk::C0[1:0]}};
  assign o = ^{pk::S1, pk::S2, pk::S3, pk::S7, pk::S10, pk::S11,
               pk::S4, pk::S5, pk::S6, pk::S9[3:0], pk::S8, pk::S12,
               pk2::T0, pk2::T1, pk2::T2, M1, M2};
endmodule
