// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  typedef struct { int k; } k_t;
  s_t a[4];
  k_t s;
  int k, r1, r2, r3, r4, r5;
  function automatic int f(int x); return x; endfunction
  initial begin
    r1 = a[k+1].v;
    r2 = a[f(k)].v;
    r3 = a[s.k].v;
    r4 = a[2].v;
  end
  assign r5 = a[k+1].v;
endmodule
