// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  typedef int t32;
  function int f(int s);
    return int'(t32'(s));
  endfunction
  assign v = f(a);
endmodule
