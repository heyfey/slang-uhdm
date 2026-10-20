// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    static int n;
    extern static function int get();
  endclass
  function int C::get();
    return n;
  endfunction
endmodule
