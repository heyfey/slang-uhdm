// § modAggCloneOwnDefOnly180v (verifier: one header typedef included in two modules, only amod has the formal writer)
module amod(output logic [7:0] o);
`include "td.svh"
  localparam op_t P = '{a: 4'h1, b: 4'h2};
  function automatic logic [7:0] f(input op_t x);
    return {x.a, x.b};
  endfunction
  assign o = f(P);
endmodule
module bmod(output logic [7:0] o);
`include "td.svh"
  localparam op_t Q = '{a: 4'h3, b: 4'h4};
  assign o = Q;
endmodule
module top(output logic [7:0] o1, o2);
  amod ua(.o(o1));
  bmod ub(.o(o2));
endmodule
