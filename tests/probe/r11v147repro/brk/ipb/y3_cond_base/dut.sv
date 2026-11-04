// § vsIpsBaseNamesByIps147
module top (input logic c, input logic [2:0] a, input logic [2:0] b, input logic [1:0][7:0] w, output logic [1:0] o);
  always_comb begin : blk
    o = w[0][(c ? a : b) +: 2];
  end
endmodule
