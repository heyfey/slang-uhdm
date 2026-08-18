// r10uvm95 grid B — $bits(<arg>) over MODULE SIGNALS / package fn locals / formals.
package pB95;
  typedef struct packed { bit [11:0] hi; bit [3:0] lo; } sp95_t;
  typedef struct packed { sp95_t inner; bit [1:0] tag; } sn95_t;
endpackage

module mB95(output int o);
  import pB95::*;
  typedef bit [9:0] tv95_t;
  byte        b1;
  bit [31:0]  v32;
  sp95_t      st;
  sn95_t      sn;
  tv95_t      tv;
  byte        arr4 [4];
  bit [7:0]   pk4  [4];
  sp95_t      sarr [2];
  byte        dyn  [];
  byte        que  [$];
  string      str;
  real        rl;
  int         md [2][3];
  int r;
  initial begin
    r = $bits(b1);
    r = $bits(v32);
    r = $bits(v32[7:0]);
    r = $bits(v32[3]);
    r = $bits(st);
    r = $bits(st.hi);
    r = $bits(sn.inner);
    r = $bits(sn.inner.lo);
    r = $bits(tv);
    r = $bits(arr4);
    r = $bits(arr4[1]);
    r = $bits(pk4[1]);
    r = $bits(pk4[1][3]);
    r = $bits(sarr[1]);
    r = $bits(sarr[1].hi);
    r = $bits(dyn);
    r = $bits(dyn[1]);
    r = $bits(que[1]);
    r = $bits(str);
    r = $bits(rl);
    r = $bits(md);
    r = $bits(md[1]);
    r = $bits(md[1][1]);
    r = $bits(sp95_t);
    r = $bits(byte);
    o = r;
  end
endmodule
