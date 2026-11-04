// § genCaReplCountUnsizedClone282
module top (input logic [7:0] e, output logic [7:0] q [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam int W = 2 + g;
    assign q[g] = {W{e[1:0]}} | '0;
  end
endmodule
