// § newArrayPartSelStripped227
package p;
class c #(int W = 4);
  logic [7:0] v; int k;
  function void f();
    int la[];
    la = new[v[k+:W]];
    la = new[v[W-1:0]];
  endfunction
endclass
endpackage
module top;
  p::c #(2) h;
endmodule
