// § modAggCloneTakesFile180v (verifier: one module includes the header typedef; two parameterizations)
module amod #(parameter int K = 1) (output logic [7:0] o);
`include "td.svh"
  localparam op_t P = '{a: K[3:0], b: 4'h2};
  function automatic logic [7:0] f(input op_t x);
    return {x.a, x.b};
  endfunction
  assign o = f(P);
endmodule
module top(output logic [7:0] o1, o2);
  amod #(1) ua(.o(o1));
  amod #(2) ub(.o(o2));
endmodule
