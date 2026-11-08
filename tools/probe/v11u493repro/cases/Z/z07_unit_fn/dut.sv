// § enumCastChainKeepsInnerCast493
typedef int ut32;
module top(input int a, output int v);
  function int f(int s);
    return int'(ut32'(s));
  endfunction
  assign v = f(a);
endmodule
