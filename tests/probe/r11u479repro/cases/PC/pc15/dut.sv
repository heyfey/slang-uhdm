// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
  function void show(int x); endfunction
endclass
class d extends base;
  function void w(int a);
    show((super.m(a)));
  endfunction
endclass
module top; endmodule
