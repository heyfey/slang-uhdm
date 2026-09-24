// b4 — PROGRAM body.  emitTypedefs runs for every InstanceBodySymbol, so a
// program-body typedef takes the flag too.  Surelog's CompileProgram.cpp:301
// also hands a hard Reduce::No, so golden should agree — MEASURE it, do not
// assume.  A checker body sits beside it.
program prg #(parameter int N = 4, parameter int DEPTH = 8) (input logic clk);
  typedef logic [N-1:0] pmem_t [DEPTH];
  pmem_t pm;
  initial pm[0] = '0;
endprogram

module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic o
);
  typedef logic [N-1:0] mmem_t [DEPTH];
  mmem_t mm;
  prg #(.N(N), .DEPTH(DEPTH)) p1 (.clk(clk));
  assign o = mm[0][0];
endmodule
