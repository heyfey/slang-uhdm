// § callArgInSelIdxChainName201
typedef struct { int f[4]; } s_t;
module top;
  function automatic int fx(int v); return v & 3; endfunction
  s_t s, t;
  int k, r;
  initial begin
    t.f[fx(s.f[k]) + 1] = 1;
    r = t.f[fx(s.f[k] + 1)];
    r = t.f[$clog2(s.f[k])];
  end
endmodule
