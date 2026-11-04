// § pureVirtFormalSignKwTrim247
module top;
  virtual class base;
    pure virtual function void f(int unsigned a);
    pure virtual function void g(input bit [3:0] b, int unsigned c);
  endclass
  class d extends base;
    virtual function void f(int unsigned a); endfunction
    virtual function void g(input bit [3:0] b, int unsigned c); endfunction
  endclass
  d x;
  initial x = new();
endmodule
