// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef logic [$clog2(W)-1:0] t;
  function automatic t f(t a); return a + 1; endfunction
  t x;
  initial x = f(1);
endmodule
