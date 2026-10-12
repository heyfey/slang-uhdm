// § caConstVarFoldNeedsReducibleInit301
class C;
  static function int mk(); return 5; endfunction
endclass
module child #(parameter bit P = 1) (output int o);
  int w = P ? C::mk() : 3;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
