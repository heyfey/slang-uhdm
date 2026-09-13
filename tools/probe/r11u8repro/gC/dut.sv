`define MT(__a,__b) `"__a __b`"
`define INNER thing
`define NEST `"pre `INNER post`"
`define MID(__x) `"__x   \
   tail`"
`define C1M(__a,__b) $display("C1M", \
    `MT(__a,__b));
`define C1N $display("C1N", \
    `NEST);
`define C1MID(__n) $display("C1MID", \
    `MID(__n));
module top;
  initial begin
    $display("C0M", `MT(aa,bb));
    $display("C0N", `NEST);
    $display("C0MID", `MID(zz));
    `C1M(pp,qq)
    `C1N
    `C1MID(rr)
  end
endmodule
