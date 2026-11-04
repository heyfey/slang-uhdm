// § idxQualCallNameSpan310
package p; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [3:0] k; logic [3:0][7:0] g; logic [7:0] f; } e_t;
class item; int f; int k; function int get(); return f; endfunction endclass
class grid;
  item iarr[4]; int r; int i; bit c; int ia[4];
  function void probe();
    r = iarr[p::f(i)].f;
    r = ia[p::f(i)];
    r = p::f(i);
    r = iarr[1].k + p::f(i);
    r = iarr[c ? p::f(i) : 0].f;
    r = iarr[p::f(i) + 1].f;
    iarr[p::f(i)].f = r;
  endfunction
endclass
module top(input logic [1:0] i, input logic c, output logic [7:0] r, output logic [7:0] q, output logic [7:0] s, output logic [7:0] t);
  e_t sa [4]; logic [7:0] m [4];
  always_comb r = sa[p::f(i)].f;
  assign q = m[p::f(i)];
  assign s = p::f(i);
  assign t = sa[1].g[p::f(i)];
endmodule
