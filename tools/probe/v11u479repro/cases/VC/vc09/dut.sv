// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
  virtual function int z(); return 1; endfunction
endclass
class d extends base;
  function int m(int a); int x; x = ((super.m(a))); return x; endfunction
endclass
module top; endmodule
