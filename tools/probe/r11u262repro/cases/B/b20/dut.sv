// § genIpsOvrParamOwner262 (width from an expression of two overridden parameters, and a localparam width)
module m #(parameter int Width = 32, parameter int Off = 0, parameter bit E = 0) (input logic [7:0] a, output logic [2:0] q, output logic [1:0] r);
  localparam int LW = 2;
  if (!E) begin : gn
    assign q = a[Off+:Width];
    assign r = a[0+:LW];
  end
endmodule
module top(input logic [7:0] a, output logic [2:0] q, output logic [1:0] r);
  m #(.Width(3), .Off(1)) u (.*);
endmodule
