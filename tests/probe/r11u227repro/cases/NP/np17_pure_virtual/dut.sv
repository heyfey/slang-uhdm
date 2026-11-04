// § newArrayPartSelStripped227
package p;
virtual class b;
  pure virtual function void f();
endclass
class c extends b;
  logic [7:0] v; int k;
  virtual function void f();
    int la[];
    la = new[v[k+:2]];
  endfunction
endclass
endpackage
module top; endmodule
