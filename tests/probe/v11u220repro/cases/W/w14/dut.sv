// § newArrayCallArgStripped220
package q;
  function automatic int g(int a); return a; endfunction
endpackage
package p;
  class c;
    int d[];
    function void f(int n);
      d = new[q::g(n)];
    endfunction
  endclass
endpackage
module top; endmodule
