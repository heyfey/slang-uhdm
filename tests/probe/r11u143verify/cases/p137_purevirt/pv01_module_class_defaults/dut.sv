// § pureVirtProtoSpan137
// case pv01: a pure virtual function with default and multi-line arguments in a class inside a module
module top();
  virtual class Base;
    pure virtual function void f(input int a = 1,
                                 output int b);
  endclass
endmodule
