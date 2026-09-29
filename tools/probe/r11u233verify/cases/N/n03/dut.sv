// § newArrayPartSelStripped227 — part-select bounds that are other selects
package p;
localparam logic [3:0] PA = 4'b0110;
class c;
  logic [7:0] v; int k; logic [7:0] w;
  function void f();
    int la[];
    la = new[v[w[2:0] +: 2]];
    la = new[v[w[1] +: 2]];
    la = new[v[w[k] -: 1]];
    la = new[v[PA[1]:0]];
  endfunction
endclass
endpackage
module top; endmodule
