// § hoistPoolSourceOrder240: a virtual base with a pure virtual prototype, an override's extern prototype below its caller, a typedef'd specialization
package hp;
  virtual class vb;
    int st;
    pure virtual function int pv();
    extern function int caller();
  endclass
  function int vb::caller();
    return pv() + st;
  endfunction
  class pz #(type T = int) extends vb;
    T st2;
    extern function new();
    extern virtual function int pv();
  endclass
  function pz::new();
    st2 = 0;
  endfunction
  function int pz::pv();
    return st + st2;
  endfunction
  typedef pz#(byte) pzb_t;
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
