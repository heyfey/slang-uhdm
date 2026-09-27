// § blockSizeDimEndsAtExpr183 (system call size)
module top(output int o);
  function automatic int f();
    begin
      int q[$bits(byte)];
      q[2] = 7;
      return q[2];
    end
  endfunction
  assign o = f();
endmodule
