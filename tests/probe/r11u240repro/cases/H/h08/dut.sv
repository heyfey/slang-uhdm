// § hoistPoolSourceOrder240: two packages imported by one module keep their own order
package p1;
  class zb;
    int w;
    extern function int get();
  endclass
  function int zb::get();
    return w;
  endfunction
endpackage
package p0;
  class aa;
    int w;
    extern function int get();
  endclass
  function int aa::get();
    return w;
  endfunction
endpackage
module top;
  import p1::*;
  import p0::*;
  initial $display("x");
endmodule
