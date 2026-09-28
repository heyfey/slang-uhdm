// § callArgInSelIdxChainName201
typedef struct { int f[4]; } s_t;
module top;
  function automatic int fx(int v); return v & 3; endfunction
  s_t s, t, u;
  int k, r;
  initial begin
    t.f[fx(s.f[u.f[k]])] = 1;
    r = t.f[fx(s.f[fx(u.f[k])])];
    t.f[fx(s.f[k])]++;
  end
endmodule
