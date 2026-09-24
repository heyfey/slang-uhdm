// § constCallNameSpan137
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top(output int o, output int p);
  function automatic int f(input int x); return x + 1; endfunction
  assign o = f(2) + q::w(3);
  if (1) begin : g
    assign p = q::w(1) + f(1);
  end
endmodule
