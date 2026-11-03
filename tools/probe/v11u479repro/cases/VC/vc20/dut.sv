// § parenCallCallee479
class base;
  virtual function int m(int a); return a; endfunction
endclass
class d extends base;
  extern function int m(int a);
endclass
function int d::m(int a); return (super.m(a)); endfunction
module top; endmodule
