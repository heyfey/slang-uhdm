// residue (no law landed): goal-1 shape u.mk(x).a[2], Surelog rejects it, see README
typedef struct { int a[4]; } s_t;
interface ifc;
  function s_t mk(int x); s_t s; s.a[2] = x; return s; endfunction
endinterface
module top;
  ifc u();
  int v;
  initial v = u.mk(3).a[2];
endmodule
