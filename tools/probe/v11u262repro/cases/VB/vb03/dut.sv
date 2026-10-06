// § genIpsOvrParamOwner262 (an if-generate, the indexed part select as a function-call argument and under a unary)
module sub #(parameter int Width = 4, parameter bit E = 1) (input logic [15:0] a, output logic [3:0] o, output logic p);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  if (E) begin : gn
    assign o = f(a[0 +: Width]);
    assign p = &a[2 +: Width];
  end
endmodule
module top(input logic [15:0] a, output logic [3:0] o, output logic p);
  sub #(.Width(4)) u(.a(a), .o(o), .p(p));
endmodule
