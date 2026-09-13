// v6 -- a continuation INSIDE the stringification, in front of the FIRST
// body token, with body whitespace written before the backslash.
`define MIDF(__x) `"   \
  __x`"
`define CALL6(__x) $display("%0s",  \
     `MIDF(__x));
module top;
  initial begin
    $display("%0s", `MIDF(m0));
    `CALL6(m1)
  end
endmodule
