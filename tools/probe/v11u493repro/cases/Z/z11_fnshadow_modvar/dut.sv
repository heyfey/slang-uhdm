// § enumCastChainKeepsInnerCast493
module top(input int a, output longint v);
  typedef int t_t;
  function longint f();
    typedef longint t_t;
    return longint'(t_t'(a));
  endfunction
  assign v = f();
endmodule
