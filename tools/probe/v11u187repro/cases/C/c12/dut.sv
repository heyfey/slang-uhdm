// § blockSizeDimEndsAtExpr183 (size then range dimension)
module top(output int o);
  function automatic int f();
    begin
      int q[2][0:1];
      q[0][1] = 5;
      return q[0][1];
    end
  endfunction
  assign o = f();
endmodule
