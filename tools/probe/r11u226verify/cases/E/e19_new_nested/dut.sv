// § newArrayCallArgStripped220 § newArrayBitSelIdxStripped220 — new[] sized by nested calls, a system call on an array, a two-level bit select and a method call
package p;
class c;
  int arr [4][4];
  int q [];
  function int g(int a); return a + 1; endfunction
  function int h(int a, int b); return a * b; endfunction
  function void f(int n, int i, int j);
    int d1 []; int d2 []; int d3 []; int d4 [];
    d1 = new[h(g(n), n)];
    d2 = new[$size(q)];
    d3 = new[arr[i][j]];
    d4 = new[this.g(n)];
  endfunction
endclass
endpackage
module top; endmodule
