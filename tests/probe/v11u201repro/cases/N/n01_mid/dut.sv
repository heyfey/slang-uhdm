// § callArgInSelIdxChainName201
typedef struct { int f[4]; int g; } s_t;
typedef struct { s_t f[4]; } t_t;
module top;
  function automatic int fx(int v); return v & 3; endfunction
  s_t s;
  t_t t;
  int k, r;
  initial begin
    t.f[fx(s.f[k])].g = 1;
    r = t.f[fx(s.f[k])].g;
  end
endmodule
