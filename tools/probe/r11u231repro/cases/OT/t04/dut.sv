// § oobClassTdFirstClassKey231 — three classes, the method's class key in the middle
package p;
  class zed;
    typedef zed this_type;
  endclass
  class mid;
    typedef mid this_type;
    extern function void put(this_type v);
  endclass
  class bee;
    typedef bee this_type;
  endclass
  function void mid::put(this_type v);
  endfunction
endpackage
module top;
endmodule
