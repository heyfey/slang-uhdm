// § oobClassTdFirstClassKey231 — the out-of-body definition written by a macro
`define DEF(C) function void C::put(this_type v); endfunction
package p;
  class cmpA;
    typedef cmpA this_type;
  endclass
  class lib;
    typedef lib this_type;
    extern function void put(this_type v);
  endclass
  `DEF(lib)
endpackage
module top;
endmodule
