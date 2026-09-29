// § newArrayPartSelStripped227
`define NEWP(a, b) a = new[b];
package p;
class c;
  logic [7:0] v; int k;
  function void f();
    int la[];
    `NEWP(la, v[k+:2])
  endfunction
endclass
endpackage
module top; endmodule
