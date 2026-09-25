// § vsIpsBaseNamesByIps147
module top (input logic [2:0] b, input logic [1:0][7:0] w, output logic [3:0] o);
  always_comb begin : blk
    o = w[1][{2{b[1]}}+:4];
  end
endmodule
