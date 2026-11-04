// § newArrayPartSelStripped227 — part-select bounds that are system calls
package p;
class c;
  logic [7:0] v; int k; logic [7:0] w;
  function void f();
    int la[];
    la = new[v[$clog2(k) +: 2]];
    la = new[v[$bits(w)-1:0]];
  endfunction
endclass
endpackage
module top; endmodule
