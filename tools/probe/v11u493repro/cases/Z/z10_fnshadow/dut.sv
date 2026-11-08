// § enumCastChainKeepsInnerCast493
module top(input int a, output longint v);
  typedef int t_t;
  function longint f(int s);
    typedef longint t_t;
    return longint'(t_t'(s));
  endfunction
  assign v = f(a);
endmodule
