// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
  virtual function int z(); return 1; endfunction
endclass
class d extends base;
  function void w(int a); $display("%0d", (super.m(a))); endfunction
endclass
module top; endmodule
