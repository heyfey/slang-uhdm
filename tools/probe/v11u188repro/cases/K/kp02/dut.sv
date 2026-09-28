// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int unsigned);
    T p;
    function T get();
      T v;
      v = p;
      return v;
    endfunction
  endclass
endpackage
module top; endmodule
