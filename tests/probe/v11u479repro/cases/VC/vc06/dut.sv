// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
  virtual function int z(); return 1; endfunction
endclass
class d extends base;
  function int w(); return (this.z()) + (super.z()); endfunction
endclass
module top; endmodule
