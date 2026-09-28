// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = bit signed);
    T p;
    function void set(input T x);
      T v;
      v = x;
      p = v;
    endfunction
  endclass
endpackage
module top; endmodule
