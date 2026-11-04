// § modAggClonePerDefKey191: one header struct typedef included in two modules, only the second with a formal writer, both instantiated
module amod(output logic [1:0] o);
`include "td.svh"
  localparam op_t P = '{a:2'h1, b:2'h2};
  assign o = P.a;
endmodule
module bmod(output logic [1:0] o);
`include "td.svh"
  function automatic logic [1:0] g(input op_t y); return y.b; endfunction
  localparam op_t Q = '{a:2'h3, b:2'h0};
  assign o = g(Q);
endmodule
module top(output logic [1:0] o1, o2);
  amod ua(o1);
  bmod ub(o2);
endmodule
