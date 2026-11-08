// § enumCastChainKeepsInnerCast493
module sub;
  typedef logic [63:0] t32;
  int a;
endmodule
module top(output int v);
  typedef int t32;
  sub u();
  function int f();
    return int'(t32'(u.a));
  endfunction
  assign v = f();
endmodule
