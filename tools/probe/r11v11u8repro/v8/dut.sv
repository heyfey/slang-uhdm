// v8 — plain (non-stringified) string literals with leading whitespace,
// inside a macro body reached across a continuation. Must be untouched.
`define PLAINSTR(__x)  $display("%0s",   \
        "   literal with lead", __x);
module top; initial begin `PLAINSTR("   another") end endmodule
