// § namedTypeLocalTfItemOutsideClass426
module child;
  typedef logic [3:0] nib_t;
  function nib_t f;
    nib_t x;
    nib_t y;
    x = 1;
    f = x;
  endfunction
  initial $display(f());
endmodule
module top;
  child c1();
  child c2();
endmodule
