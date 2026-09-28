// § callArgInSelIdxChainName201
typedef struct { int f[4]; } s_t;
class K;
  int a[4];
  function int idx(int v); return v & 3; endfunction
  function void t(s_t s, int k);
    a[idx(s.f[k])] = 1;
    this.a[idx(s.f[k])] = 2;
  endfunction
endclass
module top;
  K kk;
  s_t s;
  initial begin kk = new; kk.t(s, 1); kk.a[kk.idx(s.f[1])] = 3; end
endmodule
