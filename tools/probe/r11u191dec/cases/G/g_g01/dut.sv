// law modAggTfArgCloneFollows180 law modAggCloneOwnDefOnly180v law modAggCloneTakesFile180v (r11u190: one header typedef in amod and bmod, BOTH with a formal writer; cmod declares its own op_t at the same line and column in its own file)
module amod(output logic [3:0] o);
`include "td.svh"
  function automatic logic [3:0] f(input op_t x); return x.a; endfunction
  localparam op_t P = '{a:4'h1, b:4'h2};
  assign o = f(P);
endmodule
module bmod(output logic [3:0] o);
`include "td.svh"
  function automatic logic [3:0] g(input op_t y); return y.b; endfunction
  localparam op_t Q = '{a:4'h3, b:4'h4};
  assign o = g(Q);
endmodule
module top(output logic [3:0] o1, o2, o3);
  amod ua(o1);
  bmod ub(o2);
  cmod uc(o3);
endmodule
