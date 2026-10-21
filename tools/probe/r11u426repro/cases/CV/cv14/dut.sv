// § namedTypeLocalTfItemOutsideClass426
typedef logic [3:0] nib_t;
module top;
  function integer test;
    nib_t x;
    test = x;
  endfunction
endmodule
