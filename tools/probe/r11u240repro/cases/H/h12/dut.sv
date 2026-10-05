// § hoistPoolSourceOrder240: a parameterized class, a pure virtual prototype, extern above and below its caller
package hp;
  virtual class zv;
    int s;
    pure virtual function int pv();
    extern function int caller();
    extern function int callee();
  endclass
  function int zv::caller();
    return callee() + s;
  endfunction
  function int zv::callee();
    return s;
  endfunction
  class aa #(parameter int W = 4);
    int s;
    logic [W-1:0] v;
    extern function int get();
  endclass
  function int aa::get();
    return s + v;
  endfunction
  typedef aa#(8) aa8;
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
