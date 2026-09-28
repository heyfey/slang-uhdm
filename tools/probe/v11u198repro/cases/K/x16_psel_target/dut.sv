// § genCaCastRhsRefUnnamed198
module top (input logic s, input logic [3:0] b, output logic [7:0] y4);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y4[i*4+:4] = 4'(b[i]);
  end
endmodule
