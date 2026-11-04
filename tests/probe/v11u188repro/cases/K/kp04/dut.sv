// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    T p;
    extern function void set(T x);
    extern function T get();
  endclass
  function void c::set(T x);
    T v;
    v = x;
    p = v;
  endfunction
  function c::T c::get();
    return p;
  endfunction
endpackage
module top; endmodule
