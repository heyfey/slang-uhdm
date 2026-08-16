class leaf; int f; endclass
class mid_c; leaf sub[4]; int idx[4]; endclass
class top_c;
  mid_c m[4];
  leaf  l[4];
  int   midx[4];
  int   j, k;
  function int probe();
    int i; int r;
    r = m[midx[i]].sub[j].f;         // k1 TWO selects, first mid with sel idx
    r = m[j].sub[midx[i]].f;         // k2 second component sel idx
    r = m[midx[i]].sub[midx[j]].f;   // k3 both
    r = l[i ? midx[j] : k].f;        // k4 ternary containing a select
    r = l[midx[i > 0 ? j : k]].f;    // k5 select whose index is a ternary
    m[midx[i]].sub[j].f = 1;         // k6 LVALUE two selects
    r = m[midx[i]].idx[j];           // k7 select mid, trailing sel no member
    return r;
  endfunction
endclass

module mtop;
  typedef struct { int f; } st;
  typedef struct { st s[4]; } outer_t;
  outer_t o[4];
  int  mi[4];
  int  z;
  initial begin
    z = o[mi[z]].s[1].f;             // k8 module, nested struct, two selects
    o[mi[z]].s[1].f = 2;             // k9 module lvalue
  end
endmodule
