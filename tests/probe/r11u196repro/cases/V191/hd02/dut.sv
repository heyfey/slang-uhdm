// § modAggClonePerDefKey191: one header typedef included in two modules, each with a formal writer in a task, one module instantiated twice
module amod(output logic [1:0] o);
`include "td.svh"
  task automatic t(input op_t x, output logic [1:0] r); r = x.a; endtask
  localparam op_t P = '{a:2'h1, b:2'h2};
  always_comb t(P, o);
endmodule
module bmod(output logic [1:0] o);
`include "td.svh"
  function automatic logic [1:0] g(input op_t y); return y.b; endfunction
  localparam op_t Q = '{a:2'h3, b:2'h0};
  assign o = g(Q);
endmodule
module top(output logic [1:0] o1, o2, o3);
  amod ua(o1);
  amod ub(o3);
  bmod uc(o2);
endmodule
