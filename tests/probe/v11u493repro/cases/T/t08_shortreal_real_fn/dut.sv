// § enumCastChainKeepsInnerCast493
module top(input real a, output int v);
  function int f(real s);
    shortreal r;
    r = shortreal'(real'(s));
    return int'(r);
  endfunction
  assign v = f(a);
endmodule
