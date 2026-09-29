// § hpLvSelIdxNamesByPath224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  function automatic s_t f(logic [1:0] i, logic [1:0] d);
    s_t s;
    s = '0;
    s.arr[i][1:0] = d;
    return s;
  endfunction
endpackage
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  assign o = p::f(i, d);
endmodule
