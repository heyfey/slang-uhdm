// § classRetFillUnsized433
module top;
  class C;
    static function logic [3:0] f(); return '1; endfunction
  endclass
  logic [3:0] q; initial q = C::f();
endmodule
