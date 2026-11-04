// § newArrayPartSelStripped227 — part-select bounds that are parameters
package p;
localparam int P = 3;
class c;
  logic [7:0] v; int k; logic [7:0] w;
  function void f();
    int la[];
    la = new[v[P-1:0]];
    la = new[v[k +: P]];
    la = new[v[P -: 2]];
  endfunction
endclass
endpackage
module top; endmodule
