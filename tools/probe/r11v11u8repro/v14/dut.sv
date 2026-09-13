// v14: a nested macro with an EMPTY body at the front of the stringification,
// with and without a leak.
`define EMPTY
`define NM4 `"`EMPTY  tail`"
`define C4 $display("[%0s]",    \
      `NM4);
module top;
  initial begin
    $display("[%0s]", `NM4);
    `C4
  end
endmodule
