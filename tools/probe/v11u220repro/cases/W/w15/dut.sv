// § newArrayCallArgStripped220
package p;
  typedef struct { int n; } s_t;
  class c;
    int d[];
    s_t s;
    function int g(int a); return a; endfunction
    function void f();
      d = new[g(s.n)];
    endfunction
  endclass
endpackage
module top; endmodule
