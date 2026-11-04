// § parenCallCallee479
class base;
  int k;
  virtual function int m(int a); return a; endfunction
endclass
class d extends base;
  function int m(int a);
    return (this.m(a)) + (super.m(a));
  endfunction
endclass
module top; endmodule
