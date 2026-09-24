`define LIT `"  hello  `"
`define QLIT "  quoted  "
`define STR(__x) `"[__x]`"
module top;
  initial begin
    $display("%0s", `LIT);
    $display("%0s", `QLIT);
    $display("%0s", `STR(  arg  ));
  end
endmodule
