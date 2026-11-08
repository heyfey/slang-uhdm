// § enumCastChainKeepsInnerCast493
module top(input int a, input int b, input logic c, output int v);
  typedef int t32;
  function int f(int x, int y, logic s);
    return int'(t32'(s ? x : y));
  endfunction
  assign v = f(a, b, c);
endmodule
