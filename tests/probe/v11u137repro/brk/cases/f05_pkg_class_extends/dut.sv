// § pureVirtProtoSpan137
package p;
  virtual class B;
    pure virtual function int f(int x);
  endclass
  class D extends B;
    virtual function int f(int x); return x; endfunction
  endclass
endpackage
module top(); endmodule
