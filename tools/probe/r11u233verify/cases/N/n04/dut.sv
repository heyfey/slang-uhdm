// § newArrayPartSelStripped227 — part-select bounds that are class members through this
package p;
class c;
  logic [7:0] v; int k; logic [7:0] w;
  function void f();
    int la[];
    la = new[v[this.k +: 2]];
    la = new[v[this.w[k] -: 2]];
  endfunction
endclass
endpackage
module top; endmodule
