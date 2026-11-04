// § tfBodyTypedefIsItem304
package p;
  virtual class b;
    pure virtual function int g(int a);
  endclass
  class c extends b;
    int m;
    virtual function int g(int a);
      typedef bit [2:0] s_t;
      s_t v;
      v = a[2:0];
      return v + m;
    endfunction
  endclass
endpackage
module top; endmodule
