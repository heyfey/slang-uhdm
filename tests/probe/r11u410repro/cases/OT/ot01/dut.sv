// § oobUnitClsTdUnsupported410
class myclass;
  typedef logic bool;
  extern function void sub(input bool x);
endclass
function void myclass::sub(input bool x); endfunction
module test;
endmodule
