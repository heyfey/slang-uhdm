// § classTpKeywordTsAtDefault188
package p;
  class b #(type T = int);
    virtual function void put(T x); endfunction
  endclass
  class d #(type T = int) extends b #(T);
    virtual function void put(T x); endfunction
    function void extra(T y); endfunction
  endclass
endpackage
module top; endmodule
