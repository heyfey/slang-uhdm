// v10 — a WHITESPACE-ONLY stringification, with and without a leak.
`define WS `"   `"
`define CALLWS $display("[%0s]",   \
      `WS);
module top; initial begin $display("[%0s]", `WS); `CALLWS end endmodule
