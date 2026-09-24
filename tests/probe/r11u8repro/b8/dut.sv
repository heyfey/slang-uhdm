`define STR(__x) `"__x`"
`define SAME(__n) $display("a", `STR(__n));
`define CONT(__n) $display("a", \
    `STR(__n));
module top;
  initial begin
    `SAME(SameLine)
    `CONT(ContLine)
  end
endmodule
