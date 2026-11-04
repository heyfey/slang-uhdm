// § classTpKeywordTsAtDefault188
package p;
  class o #(type U = int);
    U u;
  endclass
  class c #(type T = int);
    typedef struct { T a; int b; } s_t;
    s_t s;
    o #(T) oo;
    T t;
    function void f(T v); t = v; endfunction
  endclass
endpackage
module top; endmodule
