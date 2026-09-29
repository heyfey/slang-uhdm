// § hpVarSelColumnJoin220
package p;
  typedef struct packed { logic [1:0][7:0] value; logic v; } s_t;
  function automatic logic [3:0] g(s_t rw, int idx);
    return rw.value[idx-1][3:0];
  endfunction
endpackage
module top(output logic [3:0] o); assign o = p::g(17'h0, 1); endmodule
