// § hpVarSelColumnJoin220
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  function automatic logic [1:0] g(s_t v, int i, int k);
    return v.arr[i][k+:2];
  endfunction
endpackage
module top(input logic [32:0] din, output logic [1:0] o);
  assign o = p::g(din, 1, 2);
endmodule
