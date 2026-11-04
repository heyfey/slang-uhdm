// § parenCallCallee479
class base;
  virtual function int m(int a, int b = 7); return a + b; endfunction
endclass
class d extends base;
  function int m(int a, int b = 9);
    return super.m(a);
  endfunction
endclass
module top;
endmodule
