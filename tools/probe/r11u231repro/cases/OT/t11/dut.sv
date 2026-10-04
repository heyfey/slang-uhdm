// § oobClassTdFirstClassKey231 — t02 with CRLF line ends
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
endmodule
