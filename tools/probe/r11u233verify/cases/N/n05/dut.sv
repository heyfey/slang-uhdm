// § newArrayPartSelStripped227 — two part selects in an operation and a part select inside a concatenation
package p;
class c;
  logic [7:0] v; int k; logic [7:0] w;
  function void f();
    int la[];
    la = new[v[k +: 2] + w[1:0]];
    la = new[{v[3:0], w[k +: 2]}];
  endfunction
endclass
endpackage
module top; endmodule
