// § vsIpsBaseNamesByIps147
module top (input logic [1:0] k, input logic [1:0][7:0] w, output logic [1:0] o);
  always_comb begin : blk
    o = w[1][k + 3 -: 2];
  end
endmodule
