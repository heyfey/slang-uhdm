// § hierPathSelIdxAtPath178
module top;
  typedef struct { int v; } s_t;
  s_t a[4];
  int k, x;
  function automatic int f(int y); return y; endfunction
  initial begin
    a[k+1].v++;
    --a[f(k)].v;
    x = a[k+2].v;
  end
endmodule
