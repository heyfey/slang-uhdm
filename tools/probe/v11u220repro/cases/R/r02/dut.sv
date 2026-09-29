// § importCloneSharesHomeReturn218
package p1;
  class c;
    extern static function c make();
    extern function string name();
  endclass
  function c c::make(); c h = new; return h; endfunction
  function string c::name(); return "c"; endfunction
endpackage
package p2; import p1::*; endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
