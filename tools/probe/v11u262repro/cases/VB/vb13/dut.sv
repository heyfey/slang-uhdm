// § genIpsOvrParamOwner262 (an if-generate, a class specialization's parameter as the width beside a typed parameter base)
class C #(parameter int W = 2);
endclass
module sub #(parameter int B = 4, parameter bit E = 1) (input logic [15:0] a, output logic [3:0] o);
  if (E) begin : gn
    assign o = a[B +: C#(4)::W];
  end
endmodule
module top(input logic [15:0] a, output logic [3:0] o);
  sub #(.B(4)) u(.a(a), .o(o));
endmodule
