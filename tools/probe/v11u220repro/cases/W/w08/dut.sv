// § newArrayCallArgStripped220
package p;
  class c;
    int d[];
    function int g(int a, int b = 2); return a + b; endfunction
    function void f(int n);
      d = new[g(.b(n), .a(n))];
    endfunction
  endclass
endpackage
module top; endmodule
