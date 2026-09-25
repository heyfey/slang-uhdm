// § vsIpsBaseNamesByIps147
module top #(parameter int W = 2) (input logic [1:0] k, input logic [1:0][7:0] w, output logic [W-1:0] o);
  always_comb begin : blk
    o = w[0][k*W +: W];
  end
endmodule
