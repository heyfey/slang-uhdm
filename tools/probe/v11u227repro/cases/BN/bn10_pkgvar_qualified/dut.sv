// § newArrayPartSelStripped227
package q;
  logic [7:0] g;
endpackage
package p;
class c;
  function void f();
    int la[];
    la = new[q::g[3:0]];
  endfunction
endclass
endpackage
module top; endmodule
