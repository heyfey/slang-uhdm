// § newArrayCallArgStripped220
package p;
  class base;
    function int g(int a); return a; endfunction
  endclass
  class c extends base;
    int d[];
    function void f(int n);
      d = new[super.g(n)];
    endfunction
  endclass
endpackage
module top; endmodule
