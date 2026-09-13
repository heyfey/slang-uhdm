// v3 -- a COMMENT right after the opening marker (srcLead reads 0 because the
// next source character is '/'), with and without a continuation leak.
`define CM(__x) `"/*c*/__x`"
`define CMW(__x) `"  /*c*/  __x`"
`define D(__x) $display("%0s",   \
        `CM(__x));
`define DW(__x) $display("%0s",   \
        `CMW(__x));
module top;
  initial begin
    $display("%0s", `CM(plainc));
    `D(leakc)
    `DW(leakcw)
  end
endmodule
