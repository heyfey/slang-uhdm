// § cloneLocalArrayTsParented241
package p;
  class qc;
    int v;
  endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    qc sq[string];
    sq["a"] = null;
  endfunction
endpackage
module top;
  import p::*;
  fac w;
  initial w = new();
endmodule
