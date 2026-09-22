// r11u97 arm z4 — THE `'x` AND `'z` FACES, IN THEIR OWN ARM.
// Surelog's `exitUnbased_unsized_literal` maps `x`/`X` to `paX` and everything
// else (including `z`) to `paZ`; those object types are not `paNumber_Tick1` /
// `paNumber_Tick0`, so the value road is a different one.  GOLDEN WRITES
// NOTHING ON A MISS, so this arm is kept apart: if its compile fails on either
// side it teaches ERROR RECOVERY, not golden.
package z4p;
  localparam int UXS = 'x - 0;
  localparam int UZS = 'z - 0;
  localparam int UXM = 'x * 2;
  localparam int UXB = 'x;
  localparam int UZB = 'z;
  localparam int C1S = '1 - 0;   // the live control in the SAME arm
  localparam int CSUB = 8 - 1;
endpackage
module z4_xz97 (output logic [63:0] o);
  wire signed [31:0] wUXS = z4p::UXS;
  wire signed [31:0] wUZS = z4p::UZS;
  wire signed [31:0] wUXM = z4p::UXM;
  wire signed [31:0] wUXB = z4p::UXB;
  wire signed [31:0] wUZB = z4p::UZB;
  wire signed [31:0] wC1S = z4p::C1S;
  wire signed [31:0] wCSUB = z4p::CSUB;
  assign o = {wUXS, wUZS} ^ {wUXM, wUXB} ^ {wUZB, wC1S} ^ {wCSUB, wUXS};
endmodule
