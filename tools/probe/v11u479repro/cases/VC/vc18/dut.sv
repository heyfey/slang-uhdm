// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
  virtual function int z(); return 1; endfunction
endclass
class d extends base;
  task w(output int r); r = (super.m(2)) ? (this.m(3)) : 0; endtask
endclass
module top; endmodule
