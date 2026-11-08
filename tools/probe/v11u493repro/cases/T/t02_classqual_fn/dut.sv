// § enumCastChainKeepsInnerCast493
class C;
  typedef int t32;
endclass
module top(input int a, output int v);
  function int f(int s);
    return int'(C::t32'(s));
  endfunction
  assign v = f(a);
endmodule
