// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function C clone();
  endclass
  function C C::clone();
    C r = new;
    r.x = x;
    return r;
  endfunction
endmodule
