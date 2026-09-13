// v1 — R3 shape: a stringification whose body OPENS with a nested macro
// reference, reached across a line continuation (srcLead == 0 by source,
// but the expansion may legitimately begin with whitespace).
`define INNER    thing
`define NM(__x) `"`INNER __x`"
`define PLAIN(__x) `"`INNER __x`"
`define CALL(__y) $display("%0s",   \
         `NM(__y));
module top;
  initial begin
    $display("%0s", `PLAIN(noleak));
    `CALL(leaked)
  end
endmodule
