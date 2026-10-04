// § oobClassTdFirstClassKey231 — the typedef in classes of two packages
package p;
  class zz;
    typedef zz this_type;
  endclass
endpackage
package q;
  class lib;
    typedef lib this_type;
    extern function void put(this_type v);
  endclass
  function void lib::put(this_type v);
  endfunction
endpackage
module top;
endmodule
