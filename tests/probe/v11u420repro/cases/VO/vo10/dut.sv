// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern virtual function int get();
  endclass
  function int C::get();
    return x;
  endfunction
endmodule
