// v2 — argument-borne whitespace: does golden keep an actual argument's
// leading spaces when the formal is the FIRST thing in the stringification?
`define S(__x) `"__x`"
`define P(__y) $display("%0s", `S(__y));
`define PC(__y) $display("%0s",  \
      `S(__y));
module top;
  initial begin
    `P(  spaced  )
    `PC(  spaced  )
    $display("%0s", `S(  direct  ));
  end
endmodule
