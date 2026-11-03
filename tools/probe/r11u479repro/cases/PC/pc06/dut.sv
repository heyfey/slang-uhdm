// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
  function int g(int a); return (this.m(a)); endfunction
endclass
module top;
endmodule
