// § genCaReplCountInst282
module top #(parameter int W = 2) (input logic [7:0] e, output logic [1:0] z, output logic [1:0] y);
  for (genvar g = 0; g < 1; g++) begin : gb
    assign {z, y} = {W{e[1:0]}};
  end
endmodule
