// § modAggCloneTakesFile180v (verifier: one module includes the header typedef; the formal writer in the main file)
module amod(output logic [7:0] o);
`include "td.svh"
  localparam op_t P = '{a: 4'h1, b: 4'h2};
  function automatic logic [7:0] f(input op_t x);
    return {x.a, x.b};
  endfunction
  assign o = f(P);
endmodule
module top(output logic [7:0] o1);
  amod ua(.o(o1));
endmodule
