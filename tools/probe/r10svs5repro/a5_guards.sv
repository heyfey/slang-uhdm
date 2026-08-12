// r10svs5 ARM 5 — THE GUARDS OF § vifClockingPathComponent5, one cell per
// `return false` in the predicate, so every clause of the STATED gate is
// EXECUTED and its effect is visible in the dump.
//
// Clause (4) of the gate — "the WRITTEN text immediately before the leaf's name
// token is EXACTLY `<comp>.` for each recovered component" — is the one that
// makes the recovered SPANS measurements instead of guesses, because the spans
// are computed by walking BACKWARD from the leaf token.  Cells g1..g4 write the
// same reference four ways that BREAK that assumption; the predicate must
// DECLINE on each (leaving the pristine 2-element path) rather than ship a span
// that points at the wrong characters.
//
// This is r10svs4's escaped-identifier lesson applied in advance: there, "the
// name test IS the written-keyword test" was broken by `\this `.
`define CBSEL(H) H.cb.ds
interface iface_g(input bit clock);
  logic ds;
  logic [7:0] din;
  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
  endclocking
  modport IP(clocking cb, input clock);
endinterface

class drv_g;
  virtual iface_g.IP vif;

  task go();
    // g0  CONTROL: the tight spelling — MUST become 3-element `vif.cb.ds`
    vif.cb.ds <= 1;
    // g1  SPACES around the dots
    vif . cb . ds <= 1;
    // g2  a COMMENT between handle and clocking block
    vif./*c*/cb.din <= 8'h1;
    // g3  a NEWLINE inside the path
    vif.
       cb.din <= 8'h2;
    // g4  the whole path spelled through a MACRO
    `CBSEL(vif) <= 1;
  endtask
endclass

module top_g;
  bit clock = 0;
  iface_g i_g(clock);
  drv_g d;
  initial begin
    d = new();
    d.vif = i_g;
    d.go();
  end
endmodule
