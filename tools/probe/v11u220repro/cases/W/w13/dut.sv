// § newArrayCallArgStripped220
package p;
  class c;
    int d[];
    extern function int g(int a);
    function void f(int n);
      d = new[g(n)];
    endfunction
  endclass
  function int c::g(int a); return a; endfunction
endpackage
module top; endmodule
