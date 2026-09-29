// § newArrayCallArgStripped220
package p;
virtual class b;
  pure virtual function int g(int a);
endclass
class c extends b;
  function int g(int a); return a; endfunction
  function void f(int n);
    int d[];
    d = new[this.g(n) + g(this.k)];
  endfunction
  int k;
endclass
endpackage
module top; endmodule
