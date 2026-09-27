// § blockSizeDimEndsAtExpr183 (package parameter size)
package pk; localparam int N = 3; endpackage
module top(output int o);
  function automatic int f();
    begin
      int q[pk::N];
      q[1] = 9;
      return q[1];
    end
  endfunction
  assign o = f();
endmodule
