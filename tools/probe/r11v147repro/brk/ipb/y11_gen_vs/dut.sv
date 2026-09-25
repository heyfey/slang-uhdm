// § vsIpsBaseNamesByIps147
module top (input logic [2:0] k, input logic [1:0][7:0] w, output logic [1:0][1:0] o);
  for (genvar g = 0; g < 2; g++) begin : gg
    always_comb o[g] = w[g][k + g +: 2];
  end
endmodule
