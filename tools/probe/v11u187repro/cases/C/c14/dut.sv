// § blockSizeDimEndsAtExpr183 (macro size)
`define SZ 4
module top(output int o);
  function automatic int f();
    begin
      int q[`SZ];
      q[2] = 7;
      return q[2];
    end
  endfunction
  assign o = f();
endmodule
