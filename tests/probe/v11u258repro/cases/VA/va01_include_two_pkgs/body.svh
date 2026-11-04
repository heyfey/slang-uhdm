  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c;
    local int m[rng_t];
    extern function int f(int a);
  endclass
  function int c::f(int a);
    c top; int n; top = this;
    foreach (top.m[range]) begin
      if (a >= range.lo) n++;
    end
    return n;
  endfunction
