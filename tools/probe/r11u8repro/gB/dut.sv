`define LIT `"  hello  `"
`define BRK(__x) `"[__x]`"
`define BRKL(__x) `"  [__x]  `"
`define STR(__x) `"__x`"
`define B1L(__n) $display("B1L", \
    `BRKL(__n));
`define B1B(__n) $display("B1B", \
    `BRK(__n));
`define B1S $display("B1S", \
    `LIT);
module top;
  initial begin
    $display("B0L", `LIT);
    $display("B0A", `STR(  spaced  ));
    $display("B0B", `BRK(  spaced  ));
    `B1L(NL)
    `B1B(NB)
    `B1S
  end
endmodule
