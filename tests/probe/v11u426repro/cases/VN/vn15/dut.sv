// § namedTypeLocalTfItemOutsideClass426
module top;
  typedef logic [3:0] nib_t;
  function automatic nib_t f;
    nib_t x;
    x = 4'h3;
    f = x;
  endfunction
  initial $display(f());
endmodule
