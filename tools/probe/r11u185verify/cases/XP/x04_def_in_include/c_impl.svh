  // out-of-body definitions in another file
  function byte_t c::f(byte_t a, int unsigned n = 2);
    return a << n;
  endfunction
  task c::t(input byte_t a, output byte_t b);
    b = ~a;
  endtask
