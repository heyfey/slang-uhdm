// § oobUnitClsTdUnsupported410
package p;
  class myclass;
    typedef logic [3:0] nib;
    extern function void sub(input nib x, int y);
  endclass
  function void myclass::sub(input nib x, int y); endfunction
endpackage
module test;
endmodule
