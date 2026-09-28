// § classTpKeywordTsAtDefault188
package p;
  class c #(type T1 = int, type T2 = bit, type T3 = string);
    T1 a;
    T2 b;
    T3 s;
    function void f(T2 y, T1 x, T3 z);
      a = x; b = y; s = z;
    endfunction
    function T3 g(T1 x);
      return s;
    endfunction
  endclass
endpackage
module top; endmodule
