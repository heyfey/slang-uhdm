// we.sv — PASS 15 round 2: the GENERATE-CONDITION half of the def-listing
// imported-package-parameter fold.  Corpus head:
//   flash_phy_rd.sv:181  `if (WidthMultiple == 1) begin : gen_single_word_sel`
//   golden  constant {ct=7 sz=32 dec=2}   ours  ref_obj 'WidthMultiple'
// WidthMultiple = DataWidth / BusWidth in flash_phy_pkg (a `/` init, hence the
// INT/ct7 encoding § defNetBoundPkgIntEnc already models elsewhere).
// Rows, all read in the DEF listing of work@wenp:
//   G1  gen-IF condition reads a `/`-init imported package parameter  (head)
//   G2  gen-IF condition reads the module's OWN localparam            (control)
//   G3  gen-IF condition reads the SAME param QUALIFIED (wep::WM)     (control)
//   G4  gen-IF condition reads a LITERAL-init imported package param
//       (does the INT-vs-UINT encoding follow the init operator?)
//   G5  a gen-FOR loop bound reading the same imported parameter
//   G6  a plain cont-assign read of G1's parameter (already-landed control)
package wep;
  parameter int DW = 4;
  parameter int BW = 2;
  parameter int WM = DW / BW;   // `/` init -> INT/ct7 encoding
  parameter int LIT = 3;        // literal init -> UINT/ct9 encoding
endpackage

module wenp import wep::*; (
  input  logic       req_i,
  output logic [7:0] a_o,
  output logic [7:0] b_o,
  output logic [7:0] c_o,
  output logic [7:0] d_o,
  output logic [7:0] e_o
);
  localparam int ML = 3;

  // G1 — the head shape.
  if (WM == 1) begin : gen_g1a
    assign a_o = 8'h1;
  end else begin : gen_g1b
    assign a_o = 8'h2;
  end

  // G2 — module localparam condition (control).
  if (ML == 1) begin : gen_g2a
    assign b_o = 8'h1;
  end else begin : gen_g2b
    assign b_o = 8'h2;
  end

  // G3 — the same package parameter, QUALIFIED (control).
  if (wep::WM == 1) begin : gen_g3a
    assign c_o = 8'h1;
  end else begin : gen_g3b
    assign c_o = 8'h2;
  end

  // G4 — a LITERAL-init imported package parameter.
  if (LIT == 1) begin : gen_g4a
    assign d_o = 8'h1;
  end else begin : gen_g4b
    assign d_o = 8'h2;
  end

  // G5 — a gen-FOR bound reading the imported parameter.
  for (genvar i = 0; i < WM; i++) begin : gen_g5
    assign e_o[i] = req_i;
  end

  // G6 — already-landed control: a plain def cont-assign read.
  logic [7:0] f;
  assign f = WM + 8'h1;
endmodule

module wetop;
  logic r;
  logic [7:0] a, b, c, d, e;
  wenp u0(.req_i(r), .a_o(a), .b_o(b), .c_o(c), .d_o(d), .e_o(e));
endmodule
