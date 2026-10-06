// § genLoopDirectBoundPaConst262 (a function-call argument holding the select in a for-generate)
module sub #(parameter int W = 3) (input logic [7:0] a, output logic [3:0] o [2]);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = f(a[W:0]);
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o [2]);
  sub u(.a(a), .o(o));
endmodule
