// § genCaReplCountUnsizedClone282
module top #(parameter int W = 2) (input logic [7:0] e, input logic c, output logic [7:0] q [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign q[g] = c ? {W{e[3:0]}} : '1;
  end
endmodule
