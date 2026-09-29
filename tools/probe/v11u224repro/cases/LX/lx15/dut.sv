// § hpLvSelIdxNamesByPath224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  function automatic s_t f(s_t s, logic [1:0] i, logic [1:0] d);
    s.arr[i][1:0] = d;
    return s;
  endfunction
endpackage
module top(input logic [1:0] i, output logic [32:0] o);
  assign o = p::f('0, i, 2'b11);
endmodule
