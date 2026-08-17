// h6: SCORING r10earl49's R0 — the 52-line Earlgrey_0_1/default head, which
// this pass does NOT clear and which is a DIFFERENT family from R1.
//
// The head is `sram2tlul.sv:42`
//     assign tl_o.a_size = top_pkg::TL_SZW'(SRAM_DWB);   // SRAM_DWB a localparam
// where golden keeps the whole RHS as an `operation, vpiOpType:67` with a
// `ref_obj (work@sram2tlul.SRAM_DWB)` operand and we fold it to `UINT:2`.
// Every cell below is one cont-assign whose RHS is a SIZE CAST, so golden's
// answer per cell says exactly which casts Surelog folds.
package h6p;
  parameter int unsigned SZW = 2;
endpackage

module h6_earl50 (
  input  logic [31:0] n,
  output logic [1:0]  o1, o2, o3, o5,
  output logic [31:0] o4, o6
);
  localparam int unsigned DWB = $clog2(32/8);
  localparam int unsigned W2  = 2;

  assign o1 = h6p::SZW'(DWB);      // the sram2tlul.sv:42 shape, exactly
  assign o2 = W2'(DWB);            // same, with a LOCAL parameter as the size
  assign o3 = 2'(DWB);             // literal size, parameter operand
  assign o4 = 32'(DWB) | 32'h0;    // the cast as an OPERAND of an operation
  assign o5 = 2'(3);               // literal size, literal operand
  assign o6 = 32'(n);              // cast of a NET — cannot fold at all
endmodule
