// § caConstVarFoldNeedsReducibleInit301
package p;
  class C; static function int mk(); return 6; endfunction endclass
  int w = C::mk() + 1;
endpackage
module child (output int o);
  import p::*;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
