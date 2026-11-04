// § genIpsOvrParamOwner262 (the top module's own if-generate, typed parameter as width and base)
module top #(parameter int Width = 4, parameter int B = 2, parameter bit E = 1) (input logic [15:0] a, output logic [3:0] o);
  if (E) begin : gn
    assign o = a[B +: Width];
  end
endmodule
