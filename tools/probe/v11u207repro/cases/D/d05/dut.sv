// § bitSelMethodCallIdxSpan207: method-call indices in part-select bounds, in a two-dimensional select, inside another select's index, and on a member select
package p;
typedef struct { int a[4]; } s_t;
class C;
  int m[int];
  int a2[4][4];
  logic [31:0] v;
  s_t s;
  int arr[8];
  function int gi(int a = 0); return a; endfunction
  function int f(C c);
    return v[c.gi(1) +: 2] + a2[c.gi(0)][c.gi(1)] + m[arr[c.gi(2)]] + s.a[c.gi(3)] + c.m[c.gi(1)];
  endfunction
endclass
endpackage
module top; endmodule
