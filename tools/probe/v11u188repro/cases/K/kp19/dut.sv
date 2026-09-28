// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    T p;
    class inner;
      T ip;
      function void f(T x); ip = x; endfunction
    endclass
  endclass
endpackage
module top; endmodule
