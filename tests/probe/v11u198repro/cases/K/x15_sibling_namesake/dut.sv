// § genCaCastRhsRefUnnamed198
module top (input logic s, input logic [3:0] b, output logic [2:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [2:0] t;
    assign t = 3'(b);
    assign y[i] = t;
  end
  if (1) begin : h
    logic [2:0] t;
    assign t = 3'(s);
  end
endmodule
