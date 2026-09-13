// v7 — a continuation just before the CLOSING marker (trailing side).
`define TR(__x) `"__x  \
  `"
module top; initial begin $display("[%0s]", `TR(tr0)); end endmodule
