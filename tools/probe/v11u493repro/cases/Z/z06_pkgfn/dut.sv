// § enumCastChainKeepsInnerCast493
package p;
  typedef int t32;
  function int f(int s);
    return int'(t32'(s));
  endfunction
endpackage
module top(input int a, output int v);
  assign v = p::f(a);
endmodule
