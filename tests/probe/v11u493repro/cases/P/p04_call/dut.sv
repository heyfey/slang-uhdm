// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  function int g(int s);
    return s + 1;
  endfunction
  assign v = int'(int'(g(a)));
endmodule
