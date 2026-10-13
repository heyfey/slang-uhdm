// § tfBodyTypedefForcesBegin304
package p;
  virtual class b;
    pure virtual function int g(int a);
  endclass
  class c extends b;
    virtual function int g(int a);
      typedef logic [2:0] n_t;
      return n_t'(a);
    endfunction
  endclass
endpackage
module top; endmodule
