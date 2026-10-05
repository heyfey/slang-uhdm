// § hoistPoolSourceOrder240: a free package function written between two classes' bodies
package hp;
  class zb;
    int v;
    extern function int get();
  endclass
  int v;
  function automatic int pf();
    return v;
  endfunction
  function int zb::get();
    return v;
  endfunction
  class aa;
    int v;
    extern function int get();
  endclass
  function int aa::get();
    return v;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
