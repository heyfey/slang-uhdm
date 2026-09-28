// § modAggClonePerDefKey191: a header struct and union typedef in three definitions, function writers with output formals in two, one definition instantiated in a for-generate
module am(output logic [1:0] o);
`include "td.svh"
  function automatic void w(input op_t x, output logic [1:0] r); r = x.a; endfunction
  localparam op_t P = '{a:2'h1, b:2'h2};
  always_comb w(P, o);
endmodule
module bm(output logic [1:0] o);
`include "td.svh"
  function automatic logic [1:0] g(input uo_t y); return y.o.b; endfunction
  assign o = g(4'h6);
endmodule
module cm(output logic [1:0] o);
`include "td.svh"
  op_t v;
  assign o = v.a;
endmodule
module top(output logic [1:0] o1, o2, o3, output logic [1:0] o4 [2]);
  bm ub(o2);
  cm uc(o3);
  am ua(o1);
  for (genvar i = 0; i < 2; i++) begin : g
    am ux(o4[i]);
  end
endmodule
