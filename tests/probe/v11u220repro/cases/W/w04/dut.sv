// § newArrayCallArgStripped220
package p;
  class c;
    int old[];
    int d[];
    function int g(int a); return a; endfunction
    function void f(int n);
      d = new[g(n)](old);
    endfunction
  endclass
endpackage
module top; endmodule
