// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    typedef T tt;
    tt a;
    T b;
    function void f(tt x, T y); a = x; b = y; endfunction
  endclass
endpackage
module top; endmodule
