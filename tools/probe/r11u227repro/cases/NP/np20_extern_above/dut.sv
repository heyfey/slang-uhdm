// § newArrayPartSelStripped227
package p;
class c;
  logic [7:0] v; int k;
  extern function void f();
  function void h();
    f();
  endfunction
endclass
function void c::f();
  int la[];
  la = new[v[k-:2]](la);
endfunction
endpackage
module top; endmodule
