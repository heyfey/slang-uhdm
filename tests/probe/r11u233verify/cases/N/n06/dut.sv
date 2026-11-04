// § newArrayPartSelStripped227 — a part select of a function-local variable with a local index
package p;
class c;
  logic [7:0] v; int k; logic [7:0] w;
  function void f();
    int la[];
    logic [7:0] lv; int j;
    la = new[lv[j +: 2]];
    la = new[lv[j -: 1]];
  endfunction
endclass
endpackage
module top; endmodule
