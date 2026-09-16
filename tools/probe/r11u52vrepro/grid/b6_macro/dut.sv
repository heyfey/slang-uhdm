// b6 — MACRO-SOURCED bounds.  The law's numeric test reads rawText of the
// bound's sourceRange; a bound that arrives through a macro expansion lives in
// a macro buffer, where raw text and locations are not the written ones
// (the emitter's documented getFullyOriginalLoc class).
`define W 8
`define WM1 (`W-1)
`define DIMS [`W-1:0]

module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic o
);
  // whole DIMENSION from a macro
  typedef logic `DIMS t_dims [DEPTH];
  // BOUND expression from a macro (numeric after expansion)
  typedef logic [`WM1:0] t_wm1 [DEPTH];
  // macro that expands to a plain number
  typedef logic [`W-1:0] t_w [DEPTH];
  // macro mixed with a parameter
  typedef logic [`W+N-1:0] t_mix [DEPTH];
  // control
  typedef logic [N-1:0] t_par [DEPTH];

  t_dims a_dims; t_wm1 a_wm1; t_w a_w; t_mix a_mix; t_par a_par;
  assign o = a_dims[0][0] ^ a_wm1[0][0] ^ a_w[0][0] ^ a_mix[0][0] ^ a_par[0][0];
endmodule
