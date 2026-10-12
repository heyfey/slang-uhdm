// § caConstVarFoldNeedsReducibleInit301
module child (output int o);
  class C; static function int mk(); return 6; endfunction endclass
  int w = C::mk();
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
