// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct { int k; int m; } s_t;
class item; int f; int g[4]; int k; item nx; function int get(); return f; endfunction static function int sget(); return 0; endfunction static function int sget2(int x); return x; endfunction endclass
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; int q[$]; endclass
class grid;
  localparam int N2 = 1;
  item iarr[4]; item i2[4][4]; int midx[4]; int i; int j; int r; bit c; holder h; holder harr[4]; int ia[4];
  int ib[4][4]; logic [7:0] lv; s_t s;
  function int fn(int x); return x; endfunction
  static function int sg(); return 0; endfunction
  function void probe();
    r = lv[i -: p::N];
  endfunction
  function int fwd(int x); return x; endfunction
endclass
module top; endmodule
