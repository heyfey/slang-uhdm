// § ppOutputCol166 (one-line expansions)
`define S(__x) `"__x`"
`define P(__y) $display("%0s", `S(__y));
module top;
  initial begin
    `P(  spaced  )
    $display("%0s", `S(  direct  ));
  end
endmodule
