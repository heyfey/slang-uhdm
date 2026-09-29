// § newArrayCallArgStripped220
package p;
  class c;
    int d[];
    function int g(int a); return a; endfunction
    function int h(int a); return a + 1; endfunction
    function void f(int n);
      d = new[g(h(n))];
    endfunction
  endclass
endpackage
module top; endmodule
