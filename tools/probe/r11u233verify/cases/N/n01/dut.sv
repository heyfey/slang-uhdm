// § newArrayPartSelStripped227 — part-select bounds that are calls
package p;
function automatic int g(int a); return a + 1; endfunction
class c;
  logic [7:0] v; int k; logic [7:0] w;
  function void f();
    int la[];
    la = new[v[g(2):0]];
    la = new[v[k +: g(1)]];
    la = new[v[g(k) +: 2]];
  endfunction
endclass
endpackage
module top; endmodule
