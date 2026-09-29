// § newArrayPartSelStripped227
package p;
class c;
  logic [7:0] v; int k;
  function int g(int x); return x; endfunction
  function void f();
    int la[];
    la = new[g(.x(v[k+:2]))];
    la = new[g(v[1:0])];
  endfunction
endclass
endpackage
module top; endmodule
