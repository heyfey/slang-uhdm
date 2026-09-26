// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  s_t a[4];
  int k;
  function automatic int f(int x); return x; endfunction
  initial begin
    a[k+1].v = 1;
    a[f(k)].v = 2;
  end
endmodule
