// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    T p;
    function T get();
      T v;
      v = p;
      return v;
    endfunction
  endclass
endpackage
module top;
  p::c #(byte) hb;
  p::c #() hd;
  initial begin
    hb = new;
    hd = new;
  end
endmodule
