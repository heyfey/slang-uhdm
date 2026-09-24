// v12 -- empty front argument AND a continuation leak together.
`define AB2(__a,__b) `"  __a  __b`"
`define C2(__b) $display("[%0s]",    \
      `AB2(,__b));
module top; initial begin `C2(zz) end endmodule
