// § vsIpsBaseNamesByIps147
module top (input logic [2:0] k, input logic [7:0] w [2], output logic [1:0] o);
  always_comb begin : blk
    o = w[1][k + 1 +: 2];
  end
endmodule
