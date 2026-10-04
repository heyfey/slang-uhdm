// § oobClassTdFirstClassKey231 — compilation-unit classes
class cmpA;
  typedef cmpA this_type;
endclass
class lib;
  typedef lib this_type;
  extern function void put(this_type v);
endclass
function void lib::put(this_type v);
endfunction
module top;
endmodule
