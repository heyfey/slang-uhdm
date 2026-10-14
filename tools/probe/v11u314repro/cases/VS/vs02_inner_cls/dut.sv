// § trailIdxStaticScopedCallName314
package p; localparam int N = 1; localparam logic [3:0] NL = 2; parameter NU = 2; typedef enum int {E0, E1, E2} e_t; localparam int M = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct { int k; int m; } s_t;
class item; int f; int g[4]; int k; item nx; function int get(); return f; endfunction static function int sget(); return 0; endfunction static function int sget2(int x = 1); return x; endfunction class inner; static function int isg(); return 0; endfunction endclass endclass
typedef item item_t;
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; int q[$]; holder harr[4]; endclass
class grid;
  localparam int N2 = 1;
  item iarr[4]; item i2[4][4]; int midx[4]; int i; int j; int r; bit c; holder h; holder harr[4]; int ia[4];
  int ib[4][4]; logic [7:0] lv; s_t s; string sarr[4]; int qa[$]; string sq[$]; holder hs[4]; int ih[$];
  function int fn(int x); return x; endfunction
  static function int sg(); return 0; endfunction
  function void probe();
    r = h.idx[item::inner::isg()];
  endfunction
  function int fwd(int x); return x; endfunction
endclass
module top; endmodule
