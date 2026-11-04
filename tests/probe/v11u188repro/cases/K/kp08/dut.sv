// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = real);
    T p;
    static T s;
    const T k = 1.0;
    rand int r;
    function T twice();
      T v = p * 2;
      return v;
    endfunction
  endclass
endpackage
module top; endmodule
