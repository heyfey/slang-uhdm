// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  typedef int t32;
  function int g(int s);
    return s + 1;
  endfunction
  function int f(int s);
    return int'(t32'(g(s)));
  endfunction
  assign v = f(a);
endmodule
