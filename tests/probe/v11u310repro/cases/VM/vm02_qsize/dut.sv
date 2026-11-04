// § methTailIdxNestShape310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct { int k; int m; } s_t;
typedef enum { EA, EB } e_t;
class item; int f; int g[4]; int k; item nx; function int get(); return f; endfunction function int put(int x); return x; endfunction function void run(); endfunction static function int sget(); return 0; endfunction endclass
class holder; item arr[4]; int idx[4]; int idx2[4][4]; int k; holder hh; logic [7:0] v; string s; int q[$]; endclass
class grid;
  item iarr[4]; item i2[4][4]; int midx[4]; int i; int j; int r; bit c; bit d; holder h; holder hd; holder harr[4]; int ia[4];
  string sarr[4]; e_t earr[4]; item smap[string]; s_t s; string str;
  function int fn(int x); return x; endfunction
  static function int sfn(int x); return x; endfunction
  function void probe();
    r = harr[h.k].q.size();
  endfunction

endclass
module top; endmodule
