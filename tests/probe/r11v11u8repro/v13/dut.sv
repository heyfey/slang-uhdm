// v13: empty front formal, whitespace only AFTER it, with and without a leak.
`define AB3(__a,__b) `"__a  __b`"
`define C3(__b) $display("[%0s]",     \
      `AB3(,__b));
module top;
  initial begin
    $display("[%0s]", `AB3(,yy));
    `C3(zz)
  end
endmodule
