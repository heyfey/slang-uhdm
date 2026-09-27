// § blockSizeDimEndsAtExpr183 (range then size dimension)
module top(output int o);
  function automatic int f();
    begin
      int q[0:1][2];
      q[0][1] = 5;
      return q[0][1];
    end
  endfunction
  assign o = f();
endmodule
