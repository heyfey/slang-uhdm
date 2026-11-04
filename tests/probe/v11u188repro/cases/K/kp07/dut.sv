// § classTpKeywordTsAtDefault188
package pk;
  interface class ic #(type T = int);
    pure virtual function T get();
    pure virtual function void put(T x);
  endclass
  class impl #(type T = int) implements ic #(T);
    T p;
    virtual function T get(); return p; endfunction
    virtual function void put(T x); p = x; endfunction
  endclass
endpackage
module dut;
endmodule
