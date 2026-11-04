// § aliasTdTargetTopView484 (package enum alias whose base enum has a typedef base)
package u;
  typedef logic [1:0] b_t;
  typedef enum b_t { A, B, C } e_t;
  typedef e_t e2_t;
  function automatic logic [1:0] f(logic [1:0] n);
    e2_t e;
    e = e2_t'(n);
    return e;
  endfunction
endpackage
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = u::f(i);
endmodule
