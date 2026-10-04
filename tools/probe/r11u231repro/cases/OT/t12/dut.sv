// § oobClassTdFirstClassKey231 — the package imported by a module that uses the class
package p;
  class cmpA;
    typedef cmpA this_type;
  endclass
  class lib;
    typedef lib this_type;
    extern function void put(this_type v);
  endclass
  function void lib::put(this_type v);
  endfunction
endpackage
module top;
  import p::*;
  initial begin
    lib l = new;
    l.put(l);
  end
endmodule
