// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
endclass
class d extends base;
  function int m(int a);
    if ((super.m(a)) > 0) return 1;
    return (super.m(a)) + 1;
  endfunction
endclass
module top; endmodule
