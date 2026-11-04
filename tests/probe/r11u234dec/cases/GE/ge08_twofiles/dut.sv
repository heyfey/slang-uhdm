// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: two files, the typedef's package in a.sv, the class in b.sv importing it
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
