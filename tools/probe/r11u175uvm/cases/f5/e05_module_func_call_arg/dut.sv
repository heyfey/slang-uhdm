module top;
  class wrap;
    function int f(int n); return n; endfunction
  endclass
  function automatic int g(wrap w, int k);
    return w.f(k);
  endfunction
  initial void'(g(null, 1));
endmodule
