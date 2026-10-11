// § genCaReplCountInst282
module top #(parameter int W = 2) (input logic [7:0] b, output logic [3:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [3:0] w = {W{b[g +: 2]}};
    assign z[g] = w;
  end
endmodule
