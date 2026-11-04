// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function int add(int a, int b);
  endclass
  function int C::add(int a, int b);
    int s;
    s = a + b + x;
    return s;
  endfunction
endmodule
