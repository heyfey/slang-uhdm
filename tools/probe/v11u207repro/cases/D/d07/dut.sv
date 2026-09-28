// § bitSelMethodCallIdxSpan207: method-call indices written by macros: the whole select, the index alone, and the method name from a macro argument
`define SEL(arr, h) arr[h.gi(1)]
`define IX(h, n) h.gi(n)
`define MN gi
package p;
class C;
  int m[int];
  function int gi(int a = 0); return a; endfunction
  function int f(C c);
    return `SEL(m, c) + m[`IX(c, 2)] + m[c.`MN(3)];
  endfunction
endclass
endpackage
module top; endmodule
