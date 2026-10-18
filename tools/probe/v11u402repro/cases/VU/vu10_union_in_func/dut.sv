// § unpackedUnionTdVar402
module top;
  typedef union { int i; byte b; } u_t;
  function int f(u_t x);
    return x.i;
  endfunction
endmodule
